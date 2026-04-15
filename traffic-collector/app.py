import pandas as pd
import time

# Read the traffic data from the CSV file
df = pd.read_csv('Traffic.csv')

print("Starting Traffic Collector...")
for index, row in df.iterrows():
    # Print the traffic data row by row as if it's coming from a sensor
    print(
        f"Time: {row['Time']} | Date: {row['Date']} | Day: {row['Day of the week']} | "
        f"Cars: {row['CarCount']} | Bikes: {row['BikeCount']} | Buses: {row['BusCount']} | "
        f"Trucks: {row['TruckCount']} | Total: {row['Total']} | Situation: {row['Traffic Situation']}"
    )
    time.sleep(2)  # Sleep for 2 seconds between each row
print("Traffic Collector completed.")