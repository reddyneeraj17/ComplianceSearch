import ftplib
import csv
import os

# Function to download NASDAQ-listed companies from FTP
def download_nasdaq_data():
    ftp = ftplib.FTP('ftp.nasdaqtrader.com')
    ftp.login()  # Anonymous login
    
    # Change to the directory containing symbol data
    ftp.cwd('SymbolDirectory')
    
    # Files to download from NASDAQ FTP
    nasdaq_file = 'nasdaqlisted.txt'
    
    # Download the file and store its contents
    with open(nasdaq_file, 'wb') as local_file:
        ftp.retrbinary(f'RETR {nasdaq_file}', local_file.write)
    
    ftp.quit()
    
    # Read the downloaded file
    with open(nasdaq_file, 'r') as file:
        lines = file.readlines()
    
    return lines

# Function to parse NASDAQ-listed companies and extract tickers
def parse_nasdaq_data(nasdaq_data):
    companies = []
    
    # Skip the header and process each line
    for line in nasdaq_data[1:]:
        if "|" in line:
            parts = line.split("|")
            symbol = parts[0].strip()
            name = parts[1].strip()
            market_category = parts[2].strip()  # Market category indicates the type of stock
            if market_category != 'N/A':  # Filter out non-active companies
                companies.append([symbol, name])
    
    return companies

# Function to save parsed data to CSV in the 'data' folder
def save_to_csv(companies, filename='nasdaq_tickers.csv'):
    # Ensure the 'data' directory exists
    folder_path = 'data'
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    
    # Full path for the output file
    file_path = os.path.join(folder_path, filename)
    
    # Save to CSV
    with open(file_path, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Company Name"])  # Header
        writer.writerows(companies)
    
    print(f"Data successfully saved to {file_path}")

# Main function
if __name__ == "__main__":
    # Step 1: Download NASDAQ-listed companies
    nasdaq_data = download_nasdaq_data()
    
    # Step 2: Parse the downloaded data to get the company symbols and names
    companies = parse_nasdaq_data(nasdaq_data)
    
    # Step 3: Save the data to CSV in the 'data' folder
    save_to_csv(companies)
    
    print(f"Total companies retrieved: {len(companies)}")
