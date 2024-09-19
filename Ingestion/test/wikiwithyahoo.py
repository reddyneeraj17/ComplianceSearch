import csv
import os
import pandas as pd
import yahooquery as yq
from concurrent.futures import ThreadPoolExecutor, as_completed

# Function to get S&P 500 tickers from Wikipedia
def get_sp500_tickers():
    url = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
    tables = pd.read_html(url)  # Read the tables on the page
    sp500_table = tables[0]  # The first table is the one we need
    sp500_tickers = sp500_table['Symbol'].tolist()  # Get the 'Symbol' column as a list
    return sp500_tickers

# Function to fetch detailed company profiles from Yahoo Finance
def fetch_company_profile(symbol):
    try:
        company = yq.Ticker(symbol)
        profile = company.asset_profile.get(symbol)
        quote_summary = company.summary_profile.get(symbol)
        
        # Extract relevant fields with fallbacks for company name
        if isinstance(profile, dict) and profile.get('longName'):
            company_name = profile.get('longName')
        elif isinstance(quote_summary, dict) and quote_summary.get('longName'):
            company_name = quote_summary.get('longName')
        else:
            # Use `shortName` or `quoteType` as the last fallback
            quote_type = company.quote_type.get(symbol)
            company_name = quote_type.get('shortName', symbol) if quote_type else symbol
        
        # Extract other details
        sector = profile.get('sector', 'N/A') if isinstance(profile, dict) else 'N/A'
        industry = profile.get('industry', 'N/A') if isinstance(profile, dict) else 'N/A'
        country = profile.get('country', 'N/A') if isinstance(profile, dict) else 'N/A'
        region = profile.get('state', 'N/A') if isinstance(profile, dict) else 'N/A'
        zip_code = profile.get('zip', 'N/A') if isinstance(profile, dict) else 'N/A'
        
        return [symbol, company_name, sector, industry, country, region, zip_code]

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
def save_to_csv(profiles, filename='sp500_company_profiles.csv'):
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
    # Step 1: Get S&P 500 tickers from Wikipedia
    sp500_tickers = get_sp500_tickers()
    
    # Step 2: Fetch detailed profiles for each symbol concurrently
    company_profiles = fetch_company_profiles_concurrently(sp500_tickers, max_workers=20)  # Adjust max_workers for faster execution
    
    # Step 3: Save the data to CSV in the 'data' folder
    save_to_csv(company_profiles)
    print(f"Total companies retrieved: {len(company_profiles)}")
