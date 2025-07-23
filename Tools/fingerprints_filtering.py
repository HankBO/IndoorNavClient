import numpy as np
import pandas as pd
import os

RAW_FILE = "raw_fingerprints.csv"
CSV_PATH = "/Users/haibo/Documents"
ABANDON_THRESHOLD = 2
SAMPLE_TIMES = 3
BETA_1 = 0.8
BETA_2 = 0.2
BETA_3 = 0.8
BETA_4 = 0.15
BETA_5 = 0.05

def filter_fingerprints(df):
    # for each site_id, if the number of same bssid is less than ABANDON_THRESHOLD, abandon it
    df_filtered = df.groupby(['site_id', 'bssid']).filter(lambda x: len(x) > ABANDON_THRESHOLD)

    if df_filtered.empty:
        return df_filtered

    # count number of records for each site_id and bssid, name it detected_times
    df_filtered = df_filtered.copy()
    df_filtered['detected_times'] = df_filtered.groupby(['room_external_id', 'site_id', 'bssid'])['rssi'].transform('count')    # 2. if detected_times = 2, then
    #print(df_filtered)
    result = df_filtered.groupby(['room_external_id', 'site_id', 'bssid']).apply(process_group).reset_index(drop=True)
    return result



def process_group(group):
    """
    Process each group of fingerprints based on the number of detected times.
        # for each site_id, records with the same bssid, use the index like F1(i)
    # 1.Initialization: F1(1) = rssi(1), F2(1) = rssi(1), F3(1) = rssi(1)
    #   F1(2) = BETA_1 * rssi(1) + BETA_2 * rssi(2)
    #   F2(2) = BETA_1 * F1(1) + BETA_2 * F1(2)
    #   F3(2) = BETA_1 * F2(1) + BETA_2 * F2(2)
    # Then we have rssi^(2) = F3(2) for each round n, where n = 1, 2, ...,i,  detected_times
    # 3. if detected_times >= 3, then
    #  F1(i) = BETA_3 * rssi^(i-2) + BETA_4 * rssi^(i-1) + BETA_5 * rssi(i)
    #  F2(i) = BETA_3 * F1(i-2) + BETA_4 * F1(i-1) + BETA_5 * F1(i)
    #  F3(i) = BETA_3 * F2(i-2) + BETA_4 * F2(i-1) + BETA_5 * F2(i)
    # Finally, only kepp rssi^(n) for the largest n as the value of rssi for each site_id and bssid
    """
    rssi_values = group['rssi'].values
    detected_times = len(rssi_values)
    
    if detected_times == 1:
        # Only one measurement, return as is
        final_rssi = rssi_values[0]
    elif detected_times == 2:
        # Apply 2-point filtering
        F1 = np.zeros(3)  # F1[0] unused, F1[1] = F1(1), F1[2] = F1(2)
        F2 = np.zeros(3)
        F3 = np.zeros(3)
        
        # Initialization: F1(1) = rssi(1), F2(1) = rssi(1), F3(1) = rssi(1)
        F1[1] = rssi_values[0]
        F2[1] = rssi_values[0]
        F3[1] = rssi_values[0]
        
        # Step 2: detected_times = 2
        F1[2] = BETA_1 * rssi_values[0] + BETA_2 * rssi_values[1]
        F2[2] = BETA_1 * F1[1] + BETA_2 * F1[2]
        F3[2] = BETA_1 * F2[1] + BETA_2 * F2[2]
        
        final_rssi = F3[2]
    else:
        # detected_times >= 3, apply 3+ point filtering
        F1 = np.zeros(detected_times + 1)  # Index 0 unused
        F2 = np.zeros(detected_times + 1)
        F3 = np.zeros(detected_times + 1)
        rssi_filtered = np.zeros(detected_times + 1)  # rssi^(i)
        
        # Initialization: F1(1) = rssi(1), F2(1) = rssi(1), F3(1) = rssi(1)
        F1[1] = rssi_values[0]
        F2[1] = rssi_values[0]
        F3[1] = rssi_values[0]
        rssi_filtered[1] = rssi_values[0]
        
        # Step 2: i = 2 (same as 2-point case)
        F1[2] = BETA_1 * rssi_values[0] + BETA_2 * rssi_values[1]
        F2[2] = BETA_1 * F1[1] + BETA_2 * F1[2]
        F3[2] = BETA_1 * F2[1] + BETA_2 * F2[2]
        rssi_filtered[2] = F3[2]
        
        # Step 3: i >= 3
        for i in range(3, detected_times + 1):
            F1[i] = BETA_3 * rssi_filtered[i-2] + BETA_4 * rssi_filtered[i-1] + BETA_5 * rssi_values[i-1]
            F2[i] = BETA_3 * F1[i-2] + BETA_4 * F1[i-1] + BETA_5 * F1[i]
            F3[i] = BETA_3 * F2[i-2] + BETA_4 * F2[i-1] + BETA_5 * F2[i]
            rssi_filtered[i] = F3[i]
        
        final_rssi = rssi_filtered[detected_times]

    result = group.iloc[[0]].copy()
    result['rssi'] = final_rssi
    return result


def read_csv(file_path):
    df = pd.read_csv(file_path)
    df.columns = df.columns.str.strip().str.lower()
    return df

if __name__ == "__main__":
    df = read_csv(os.path.join(CSV_PATH, RAW_FILE))
    print("DataFrame columns after cleaning:", df.columns.tolist())
    filtered_df = filter_fingerprints(df)
    filtered_df = filtered_df.drop(columns=['detected_times'])
    filtered_df['fp_id'] = filtered_df.groupby('site_id').ngroup() + 1
    filtered_df['floor_num'] = 1
    filtered_df.to_csv(os.path.join(CSV_PATH, "filtered_fingerprints.csv"), index=True)

    print("Filtered fingerprints saved to filtered_fingerprints.csv")
    print(f"Total records after filtering: {len(filtered_df)}")
    print(f"Total site_ids after filtering: {filtered_df['site_id'].nunique()}")

