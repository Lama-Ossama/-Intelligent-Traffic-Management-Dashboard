import os
import pandas as pd
import time

# TRAFFIC_CSV_PATH lets docker-compose point both the collector and the
# dashboard at the same file (see docker-compose.yml) instead of each
# reading its own baked-in copy. Defaults to the image's bundled copy so
# standalone `docker run` / Kubernetes still work with no env var set.
csv_path = os.environ.get('TRAFFIC_CSV_PATH', 'Traffic.csv')

# Read the traffic data from the CSV file
df = pd.read_csv(csv_path)

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