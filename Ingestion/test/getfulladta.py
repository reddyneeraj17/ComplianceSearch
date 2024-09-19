import ftplib
import csv
import os
import yahooquery as yq
from concurrent.futures import ThreadPoolExecutor, as_completed

# Function to download Nasdaq-listed companies from FTP
def download_nasdaq_data():
    ftp = ftplib.FTP('ftp.nasdaqtrader.com')
    ftp.login()  # Anonymous login
    
    # Change to the directory containing symbol data
    ftp.cwd('SymbolDirectory')
    
    # Files to download from Nasdaq FTP
    files_to_download = ['nasdaqlisted.txt', 'otherlisted.txt']
    downloaded_data = []
    
    for filename in files_to_download:
        # Download file and store its contents
        with open(filename, 'wb') as local_file:
            ftp.retrbinary(f'RETR {filename}', local_file.write)
        # Read the downloaded file
        with open(filename, 'r') as local_file:
            downloaded_data.append(local_file.readlines())
    
    ftp.quit()
    
    return downloaded_data

# Function to parse Nasdaq-listed companies
def parse_nasdaq_data(nasdaq_data):
    nasdaqlisted = nasdaq_data[0]
    otherlisted = nasdaq_data[1]
    
    nasdaq_companies = []
    
    # Parse nasdaqlisted.txt
    for line in nasdaqlisted:
        if "|" in line and "Symbol" not in line:  # Skip header
            parts = line.split("|")
            symbol = parts[0].strip()
            market_category = parts[2].strip()  # Common stock filter
            if market_category == "Q":  # Only include common stocks (Nasdaq Global Select Market)
                nasdaq_companies.append(symbol)
    
    # Parse otherlisted.txt
    for line in otherlisted:
        if "|" in line and "ACT Symbol" not in line:  # Skip header
            parts = line.split("|")
            symbol = parts[0].strip()
            nasdaq_companies.append(symbol)
    
    return nasdaq_companies

# Function to fetch detailed company profiles from Yahoo Finance
def fetch_company_profile(symbol):
    try:
        company = yq.Ticker(symbol)
        profile = company.asset_profile.get(symbol)
        
        if isinstance(profile, dict):
            # Extract asset_profile fields
            company_name = profile.get('longBusinessSummary', symbol)
            sector = profile.get('sector', 'N/A')
            industry = profile.get('industry', 'N/A')
            country = profile.get('country', 'N/A')
            region = profile.get('state', 'N/A')
            zip_code = profile.get('zip', 'N/A')
            
            return [symbol, company_name, sector, industry, country, region, zip_code]
        else:
            # Fallback to summary_profile if asset_profile is unavailable
            summary_profile = company.summary_profile.get(symbol)
            if isinstance(summary_profile, dict):
                company_name = summary_profile.get('longBusinessSummary', symbol)
                sector = summary_profile.get('sector', 'N/A')
                industry = summary_profile.get('industry', 'N/A')
                country = summary_profile.get('country', 'N/A')
                region = summary_profile.get('state', 'N/A')
                zip_code = summary_profile.get('zip', 'N/A')
                
                return [symbol, company_name, sector, industry, country, region, zip_code]
            else:
                print(f"No profile data for {symbol}")
                return None

    except Exception as e:
        print(f"Failed to retrieve data for {symbol}: {e}")
        return None

# Function to fetch profiles for multiple companies concurrently
def fetch_company_profiles_concurrently(symbols, max_workers=10):
    profiles = []
    
    # Use ThreadPoolExecutor to run tasks in parallel
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(fetch_company_profile, symbol): symbol for symbol in symbols}
        
        for future in as_completed(futures):
            result = future.result()
            if result:
                profiles.append(result)
    
    return profiles

# Function to save parsed data to CSV in the 'data' folder
def save_to_csv(profiles, filename='detailed_company_profiles.csv'):
    # Ensure the 'data' directory exists
    folder_path = 'data'
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    
    # Full path for the output file
    file_path = os.path.join(folder_path, filename)
    
    with open(file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Company Name", "Sector", "Industry", "Country", "Region", "Zip Code"])
        writer.writerows(profiles)
    print(f"Data successfully saved to {file_path}")

# Main function
if __name__ == "__main__":
    # Step 1: Download data from Nasdaq FTP
    nasdaq_data = download_nasdaq_data()
    
    # Step 2: Parse the downloaded data to get the company symbols
    symbols = parse_nasdaq_data(nasdaq_data)
    
    # Step 3: Fetch detailed profiles for each symbol concurrently
    company_profiles = fetch_company_profiles_concurrently(symbols, max_workers=20)  # Adjust max_workers for faster execution
    
    # Step 4: Save the data to CSV in the 'data' folder
    save_to_csv(company_profiles)
    print(f"Total companies retrieved: {len(company_profiles)}")
