import ftplib
import csv
import os
import yahooquery as yq
from concurrent.futures import ThreadPoolExecutor, as_completed

# Create the 'data' folder if it doesn't exist
os.makedirs('data', exist_ok=True)

# Function to download other listed companies from NASDAQ FTP
def download_otherlisted_data():
    ftp = ftplib.FTP('ftp.nasdaqtrader.com')
    ftp.login()  # Anonymous login
    
    # Change to the directory containing symbol data
    ftp.cwd('SymbolDirectory')
    
    # File path to save the downloaded files
    other_file = 'data/otherlisted.txt'  # Save directly in the 'data' folder
    
    # Download the file and store its contents
    with open(other_file, 'wb') as local_file_handle:
        ftp.retrbinary(f'RETR otherlisted.txt', local_file_handle.write)
    
    ftp.quit()
    
    # Read the downloaded file
    with open(other_file, 'r') as file:
        lines = file.readlines()
    
    return lines

# Function to parse the other listed companies and extract 'ACT Symbol' and 'Security Name'
def parse_otherlisted_data(otherlisted_data):
    companies = {}
    
    # Skip the header and process each line
    for line in otherlisted_data[1:]:
        if "|" in line:
            parts = line.split("|")
            symbol = parts[0].strip()  # Use 'ACT Symbol' as the ticker symbol
            name = parts[1].strip()    # Use 'Security Name' as the company name
            
            # Clean up symbols (remove special characters if necessary)
            symbol_clean = symbol.replace("$", "-").replace(".", "-")  # Replace special characters for compatibility with Yahoo Finance
            
            companies[symbol_clean] = name  # Store symbol as key, name as value
    
    return companies

# Function to fetch metadata for a given ticker symbol from Yahoo Finance
def fetch_metadata_from_yahoo(symbol, fallback_name):
    try:
        company = yq.Ticker(symbol)
        profile = company.asset_profile.get(symbol)
        quote_type = company.quote_type.get(symbol)
        
        # Use Yahoo Finance data if available, otherwise fallback to fallback_name
        company_name = profile.get('longName') if isinstance(profile, dict) else quote_type.get('shortName', fallback_name)
        sector = profile.get('sector', 'N/A') if isinstance(profile, dict) else 'N/A'
        industry = profile.get('industry', 'N/A') if isinstance(profile, dict) else 'N/A'
        country = profile.get('country', 'N/A') if isinstance(profile, dict) else 'N/A'
        region = profile.get('state', 'N/A') if isinstance(profile, dict) else 'N/A'
        zip_code = profile.get('zip', 'N/A') if isinstance(profile, dict) else 'N/A'
        
        return [symbol, company_name, sector, industry, country, region, zip_code]
    except Exception as e:
        print(f"Failed to retrieve data for {symbol}: {e}")
        return [symbol, fallback_name, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A']

# Function to fetch metadata for multiple companies in parallel
def fetch_all_metadata(companies, max_workers=10):
    profiles = []
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(fetch_metadata_from_yahoo, symbol, name): symbol for symbol, name in companies.items()}
        
        for future in as_completed(futures):
            result = future.result()
            profiles.append(result)
    
    return profiles

# Function to save parsed data to CSV in the 'data' folder
def save_to_csv(data, filename='otherlisted_with_metadata.csv'):
    file_path = os.path.join('data', filename)
    
    with open(file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Company Name", "Sector", "Industry", "Country", "Region", "Zip Code"])  # Header
        writer.writerows(data)
    
    print(f"Data successfully saved to {file_path}")

# Main function
if __name__ == "__main__":

    # Step 1: Download Other-listed companies
    otherlisted_data = download_otherlisted_data()
    
    # Step 2: Parse the downloaded data to get the ACT symbols and company names
    other_companies = parse_otherlisted_data(otherlisted_data)
    
    # Step 3: Fetch metadata for each symbol from Yahoo Finance in parallel
    metadata = fetch_all_metadata(other_companies, max_workers=20)  # Adjust max_workers for faster execution
    
    # Step 4: Save the data to CSV in the 'data' folder
    save_to_csv(metadata)
    
    print(f"Total companies retrieved: {len(metadata)}")
