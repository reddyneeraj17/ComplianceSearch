import ftplib
import csv
import os
import yahooquery as yq
import pandas as pd
from concurrent.futures import ThreadPoolExecutor, as_completed

# Create the 'data' folder if it doesn't exist
os.makedirs('data', exist_ok=True)

# Function to download data from NASDAQ FTP
def download_data(file_name):
    ftp = ftplib.FTP('ftp.nasdaqtrader.com')
    ftp.login()  # Anonymous login
    
    # Change to the directory containing symbol data
    ftp.cwd('SymbolDirectory')
    
    # File path to save the downloaded files
    local_file = f'data/{file_name}'  # Save directly in the 'data' folder
    
    # Download the file and store its contents
    with open(local_file, 'wb') as local_file_handle:
        ftp.retrbinary(f'RETR {file_name}', local_file_handle.write)
    
    ftp.quit()
    
    # Read the downloaded file
    with open(local_file, 'r') as file:
        lines = file.readlines()
    
    return lines

# Function to parse companies and extract tickers
def load_tickers_from_file(data):
    tickers = []
    for line in data[1:]:  # Skip the header
        if "|" in line:
            parts = line.split("|")
            tickers.append(parts[0].strip())  # Extract the ticker symbol
    
    return tickers

# Function to fetch metadata for a given ticker symbol from Yahoo Finance
def fetch_metadata_from_yahoo(symbol, fallback_name):
    try:
        company = yq.Ticker(symbol)
        profile = company.asset_profile.get(symbol)
        quote_type = company.quote_type.get(symbol)

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

# Function to save parsed metadata to CSV in the 'data' folder
def save_metadata_to_csv(data, filename):
    file_path = os.path.join('data', filename)
    
    # Save metadata to CSV
    with open(file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Company Name", "Sector", "Industry", "Country", "Region", "Zip Code"])  # Header
        writer.writerows(data)
    
    print(f"Metadata successfully saved to {file_path}")

# Function to fetch company name using Yahoo Finance
def fetch_company_name_yahoo(ticker):
    try:
        company = yq.Ticker(ticker)
        price_info = company.price.get(ticker, {})
        long_name = price_info.get('longName', None)
        
        if long_name:
            return [ticker, long_name]
        else:
            short_name = company.quote_type.get(ticker, {}).get('shortName', None)
            return [ticker, short_name if short_name else ticker]
    
    except Exception as e:
        print(f"Failed to retrieve company name for {ticker}: {e}")
        return [ticker, ticker]

# Function to fetch company names for multiple companies in parallel
def fetch_all_company_names(tickers, max_workers=10):
    company_names = []
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(fetch_company_name_yahoo, ticker): ticker for ticker in tickers}
        for future in as_completed(futures):
            result = future.result()
            company_names.append(result)
    return company_names

# Function to save company names and tickers to CSV
def save_company_names_to_csv(data, filename):
    file_path = os.path.join('data', filename)
    
    # Save company names to CSV
    with open(file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Company Name"])  # Header
        writer.writerows(data)
    
    print(f"Company names successfully saved to {file_path}")

# Function to join company names with metadata
def join_company_names_with_metadata(company_names_file, metadata_file, output_file):
    company_names_df = pd.read_csv(company_names_file)
    metadata_df = pd.read_csv(metadata_file)

    # Merge on 'Symbol'
    combined_df = pd.merge(metadata_df, company_names_df, on='Symbol', how='left')
    
    # Clean up column names
    if 'Company Name_x' in combined_df.columns and 'Company Name_y' in combined_df.columns:
        combined_df = combined_df.drop(columns=['Company Name_x']).rename(columns={'Company Name_y': 'Company Name'})

    combined_df = combined_df[['Symbol', 'Company Name', 'Sector', 'Industry', 'Country', 'Region', 'Zip Code']]

    # Save the combined data to CSV
    combined_df.to_csv(os.path.join('data', output_file), index=False)

    print(f"Final combined CSV saved to {os.path.join('data', output_file)}")

# Main function
if __name__ == "__main__":
    # Step 1: Download NASDAQ and Other-listed companies
    nasdaq_data = download_data('nasdaqlisted.txt')
    otherlisted_data = download_data('otherlisted.txt')

    # Step 2: Parse tickers from both NASDAQ and other-listed companies
    nasdaq_tickers = load_tickers_from_file(nasdaq_data)
    other_tickers = load_tickers_from_file(otherlisted_data)
    
    # Step 3: Fetch metadata for both NASDAQ and other-listed companies
    nasdaq_metadata = fetch_all_metadata({ticker: ticker for ticker in nasdaq_tickers}, max_workers=20)
    other_metadata = fetch_all_metadata({ticker: ticker for ticker in other_tickers}, max_workers=20)

    # Step 4: Save metadata for both NASDAQ and other-listed companies
    save_metadata_to_csv(nasdaq_metadata, 'nasdaq_with_metadata.csv')
    save_metadata_to_csv(other_metadata, 'otherlisted_with_metadata.csv')
    
    # Step 5: Fetch company names for both NASDAQ and other-listed companies
    nasdaq_company_names = fetch_all_company_names(nasdaq_tickers, max_workers=20)
    other_company_names = fetch_all_company_names(other_tickers, max_workers=20)

    # Step 6: Save the company names to CSV
    save_company_names_to_csv(nasdaq_company_names, 'nasdaq_company_names.csv')
    save_company_names_to_csv(other_company_names, 'other_company_names.csv')
    
    # Step 7: Join company names with metadata for both NASDAQ and other-listed companies
    join_company_names_with_metadata('data/nasdaq_company_names.csv', 'data/nasdaq_with_metadata.csv', output_file='nasdaq_final_combined.csv')
    join_company_names_with_metadata('data/other_company_names.csv', 'data/otherlisted_with_metadata.csv', output_file='other_final_combined.csv')

    print("Process complete.")
