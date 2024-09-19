import yahooquery as yq
import csv
import os
import pandas as pd
from concurrent.futures import ThreadPoolExecutor, as_completed

# Create the 'data' folder if it doesn't exist
os.makedirs('data', exist_ok=True)

# Function to fetch company name using Yahoo Finance
def fetch_company_name_yahoo(ticker):
    try:
        # Create Ticker object from yahooquery
        company = yq.Ticker(ticker)
        
        # Try to get the longName (full company name) from 'price'
        price_info = company.price.get(ticker, {})
        long_name = price_info.get('longName', None)
        
        if long_name:  # If longName is available
            return [ticker, long_name]
        else:
            # Fall back to shortName from 'quoteType' if longName isn't found
            short_name = company.quote_type.get(ticker, {}).get('shortName', None)
            return [ticker, short_name if short_name else ticker]  # Return shortName or ticker symbol as fallback
    
    except Exception as e:
        print(f"Failed to retrieve company name for {ticker}: {e}")
        return [ticker, ticker]  # If there's an error, return the ticker symbol as the name

# Function to fetch company names for multiple companies in parallel
def fetch_all_company_names(tickers, max_workers=10):
    company_names = []
    
    # Use ThreadPoolExecutor to run tasks in parallel
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(fetch_company_name_yahoo, ticker): ticker for ticker in tickers}
        
        for future in as_completed(futures):
            result = future.result()
            company_names.append(result)
    
    return company_names

# Function to save company names and tickers to CSV in the 'data' folder
def save_company_names_to_csv(data, filename='nasdaq_company_names.csv'):
    # Full path for the output file
    file_path = os.path.join('data', filename)
    
    # Save to CSV
    with open(file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Company Name"])  # Header
        writer.writerows(data)
    
    print(f"Company names successfully saved to {file_path}")

# Function to load tickers from the nasdaq_listed_companies.txt file
def load_tickers_from_file(filepath):
    tickers = []
    with open(filepath, 'r') as file:
        lines = file.readlines()
        for line in lines[1:]:  # Skip the header
            if "|" in line:
                parts = line.split("|")
                tickers.append(parts[0].strip())  # Extract the ticker symbol
    
    return tickers

# Function to join company names with metadata
def join_company_names_with_metadata(company_names_file, metadata_file, output_file='nasdaq_final_combined.csv'):
    # Read both CSV files into pandas dataframes
    company_names_df = pd.read_csv(company_names_file)
    metadata_df = pd.read_csv(metadata_file)

    # Debugging: Print the first few rows and columns of each file to check structure
    print("Company Names DataFrame Columns: ", company_names_df.columns)
    print("Metadata DataFrame Columns: ", metadata_df.columns)
    
    # Perform a left join on the 'Symbol' column (ticker symbol)
    combined_df = pd.merge(metadata_df, company_names_df, on='Symbol', how='left')

    # After merge, drop the 'Company Name_x' from metadata and rename 'Company Name_y' to 'Company Name'
    combined_df = combined_df.drop(columns=['Company Name_x']).rename(columns={'Company Name_y': 'Company Name'})

    # Debugging: Check the result of the merge
    print("Combined DataFrame after merge:")
    print(combined_df.head())

    # Reorder columns to put 'Company Name' in front
    combined_df = combined_df[['Symbol', 'Company Name', 'Sector', 'Industry', 'Country', 'Region', 'Zip Code']]

    # Save the combined data to the final output file
    combined_df.to_csv(os.path.join('data', output_file), index=False)

    print(f"Final combined CSV saved to {os.path.join('data', output_file)}")

# Main function
if __name__ == "__main__":
    # Step 1: Load tickers from nasdaq_listed_companies.txt
    tickers_file = 'data/nasdaqlisted.txt'  # This is the file downloaded earlier with the NASDAQ symbols
    tickers = load_tickers_from_file(tickers_file)
    
    # Step 2: Fetch company names for the tickers
    company_names = fetch_all_company_names(tickers, max_workers=20)
    
    # Step 3: Save the company names and tickers to a CSV file
    save_company_names_to_csv(company_names)
    
    # Step 4: Join company names with metadata CSV
    metadata_file = 'data/nasdaq_with_metadata.csv'  # Previously created metadata CSV
    company_names_file = 'data/nasdaq_company_names.csv'  # CSV created in step 3
    join_company_names_with_metadata(company_names_file, metadata_file)


# import yahooquery as yq
# import csv
# import os
# from concurrent.futures import ThreadPoolExecutor, as_completed

# # Create the 'data' folder if it doesn't exist
# os.makedirs('data', exist_ok=True)

# # Function to fetch company name using Yahoo Finance
# def fetch_company_name_yahoo(ticker):
#     try:
#         # Create Ticker object from yahooquery
#         company = yq.Ticker(ticker)
        
#         # Try to get the longName (full company name) from 'price'
#         price_info = company.price.get(ticker, {})
#         long_name = price_info.get('longName', None)
        
#         if long_name:  # If longName is available
#             return [ticker, long_name]
#         else:
#             # Fall back to shortName from 'quoteType' if longName isn't found
#             short_name = company.quote_type.get(ticker, {}).get('shortName', None)
#             return [ticker, short_name if short_name else ticker]  # Return shortName or ticker symbol as fallback
    
#     except Exception as e:
#         print(f"Failed to retrieve company name for {ticker}: {e}")
#         return [ticker, ticker]  # If there's an error, return the ticker symbol as the name

# # Function to fetch company names for multiple companies in parallel
# def fetch_all_company_names(tickers, max_workers=10):
#     company_names = []
    
#     # Use ThreadPoolExecutor to run tasks in parallel
#     with ThreadPoolExecutor(max_workers=max_workers) as executor:
#         futures = {executor.submit(fetch_company_name_yahoo, ticker): ticker for ticker in tickers}
        
#         for future in as_completed(futures):
#             result = future.result()
#             company_names.append(result)
    
#     return company_names

# # Function to save company names and tickers to CSV in the 'data' folder
# def save_to_csv(data, filename='nasdaq_company_names.csv'):
#     # Full path for the output file
#     file_path = os.path.join('data', filename)
    
#     # Save to CSV
#     with open(file_path, mode='w', newline='', encoding='utf-8') as file:
#         writer = csv.writer(file)
#         writer.writerow(["Symbol", "Company Name"])  # Header
#         writer.writerows(data)
    
#     print(f"Data successfully saved to {file_path}")

# # Function to load tickers from the nasdaq_listed_companies.txt file
# def load_tickers_from_file(filepath):
#     tickers = []
#     with open(filepath, 'r') as file:
#         lines = file.readlines()
#         for line in lines[1:]:  # Skip the header
#             if "|" in line:
#                 parts = line.split("|")
#                 tickers.append(parts[0].strip())  # Extract the ticker symbol
    
#     return tickers

# # Main function
# if __name__ == "__main__":
#     # Load tickers from nasdaq_listed_companies.txt
#     tickers_file = 'data/nasdaqlisted.txt'  # This is the file downloaded earlier with the NASDAQ symbols
#     tickers = load_tickers_from_file(tickers_file)
    
#     # Fetch company names for the tickers
#     company_names = fetch_all_company_names(tickers, max_workers=20)
    
#     # Save the company names and tickers to a CSV file
#     save_to_csv(company_names)
    
#     print(f"Total companies retrieved: {len(company_names)}")
