import ftplib
import csv
import os
import yahooquery as yq
from concurrent.futures import ThreadPoolExecutor, as_completed

# Create the 'data' folder if it doesn't exist
os.makedirs('data', exist_ok=True)

# Function to download NASDAQ-listed companies from FTP
def download_nasdaq_data():
    ftp = ftplib.FTP('ftp.nasdaqtrader.com')
    ftp.login()  # Anonymous login
    
    # Change to the directory containing symbol data
    ftp.cwd('SymbolDirectory')
    
    # Files to download from NASDAQ FTP
    nasdaq_file = 'data/nasdaqlisted.txt'  # Save directly in the 'data' folder
    
    # Download the file and store its contents
    with open(nasdaq_file, 'wb') as local_file:
        ftp.retrbinary(f'RETR nasdaqlisted.txt', local_file.write)
    
    ftp.quit()
    
    # Read the downloaded file
    with open(nasdaq_file, 'r') as file:
        lines = file.readlines()
    
    return lines

# Function to parse NASDAQ-listed companies and extract tickers and company names
def parse_nasdaq_data(nasdaq_data):
    companies = {}
    
    # Skip the header and process each line
    for line in nasdaq_data[1:]:
        if "|" in line:
            parts = line.split("|")
            symbol = parts[0].strip()
            name = parts[1].strip()
            market_category = parts[2].strip()  # Market category indicates the type of stock
            if market_category != 'N/A':  # Filter out non-active companies
                companies[symbol] = name  # Store symbol as key, name as value
    
    return companies


def fetch_metadata_from_yahoo(symbol, fallback_name):
    try:
        company = yq.Ticker(symbol)
        profile = company.asset_profile.get(symbol)
        quote_type = company.quote_type.get(symbol)
        
        # Use Yahoo Finance data if available, otherwise fallback to NASDAQ name
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
def save_to_csv(data, filename='nasdaq_with_metadata.csv'):

    file_path = os.path.join('data', filename)
    
    with open(file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Company Name", "Sector", "Industry", "Country", "Region", "Zip Code"])  # Header
        writer.writerows(data)
    
    print(f"Data successfully saved to {file_path}")

# Main function
if __name__ == "__main__":
    # Step 1: Download NASDAQ-listed companies
    nasdaq_data = download_nasdaq_data()
    
    # Step 2: Parse the downloaded data to get the company symbols and names
    companies = parse_nasdaq_data(nasdaq_data)
    
    # Step 3: Fetch metadata for each symbol from Yahoo Finance in parallel
    metadata = fetch_all_metadata(companies, max_workers=20)  # Adjust max_workers for faster execution
    
    # Step 4: Save the data to CSV in the 'data' folder
    save_to_csv(metadata)
    
    print(f"Total companies retrieved: {len(metadata)}")
