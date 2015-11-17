def read_csv(file_path, has_header = True):
    with open(file_path) as f:
        if has_header: 
            header = f.readline().strip().split(",")
        data = []
        for line in f:
            line = line.strip().split(",")
            data.append([float(x) for x in line])
    return header, data

def write_csv(file_path, data):
    with open(file_path,"w") as f:
        for line in data: f.write(",".join(line) + "\n")

