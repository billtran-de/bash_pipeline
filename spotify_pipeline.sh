#!/bin/bash

# remove old directories & files
rm -rf __MACOSX
rm spotify_data.csv
mkdir -p data

# extract data to CSV file
curl -L https://assets.datacamp.com/production/repositories/4180/datasets/eb1d6a36fa3039e4e00064797e1a1600d267b135/201812SpotifyData.zip --output spotfify_data.zip
unzip spotfify_data.zip && rm spotfify_data.zip
mv 201812SpotifyData.csv spotify_data.csv

# transform data
csvcut -n spotify_data.csv
csvcut -c popularity spotify_data.csv | csvstat

# define a function to write to csv file
function write_csv {
    csvcut -c artist_name,track_name,duration_ms,time_signature,popularity spotify_data.csv | csvgrep -c popularity -m $1 > data/"popularity_${2}.csv"
}

for x in $(csvcut -c popularity spotify_data.csv | sort -n | uniq)
do
    if [ $x == 25 ]; then
        write_csv $x "most_common"
    elif [ $x == 76 ]; then
        write_csv $x "most_popular"
    else
        write_csv $x $x
    fi
done

# load data to MySQL database
csvsql --db mysql+mysqldb://root:password@127.0.0.1:3306/de_sandbox --tables spotify_pipeline --insert data/popularity_most_common.csv