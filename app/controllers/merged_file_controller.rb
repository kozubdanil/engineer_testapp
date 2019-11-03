require 'csv'
require "json"

# http://localhost:3000/?sort_by=rnd&sort_type=asc [&download=true]

class MergedFileController < ApplicationController
  PATH = "app/assets/input_files/"
  JSON_FILE = PATH + "example.json"
  CSV_FILE = PATH + "example.csv"
  DOWNLOAD_FILE_NAME = "merged_file.txt"

  SORT_PARAMS = ["index", "datetime", "origin", "rnd"]

  def index
    sort_by_param = params["sort_by"]

    if SORT_PARAMS.find_index(sort_by_param).nil?
      @merged_data = [error: "wrong sort_by parameter"]
      return
    end

    #generate_json_file
    #generate_csv_file

    json_data = read_json_file
    csv_data = read_csv_file

    json_data.concat csv_data

    @merged_data = json_data.sort_by { |k| k[sort_by_param] }

    if params.key?("sort_type") && params["sort_type"] == "desc"
      @merged_data.reverse!
    end

    if params.key?("download")
      send_data @merged_data.to_json.to_s, :filename => DOWNLOAD_FILE_NAME
    else
      respond_to do |format|
        format.html
        format.json { render json: @merged_data.to_json.to_s }
      end
    end
  end

  private

  def read_json_file
    f = File.open(JSON_FILE, "r").read
    JSON.parse(f)
  end

  def read_csv_file
    data = CSV.read(CSV_FILE, { encoding: "UTF-8", headers: true, converters: :all})
    data.map { |d| d.to_hash }
  end

  def generate_json_file
    json_array = []

    (0..10).each do |n|
      json_array << create_data(n.to_i, DateTime.now + n.days, "text is " + DateTime.now.to_s,"json", rand(1..10))
    end

    f = File.open(JSON_FILE,'w')
    f.write(json_array.to_json)
    f.close
  end

  def generate_csv_file
    csv_array = []

    (11..20).each do |n|
      csv_array << create_data(n.to_i, DateTime.now + n.days, "text is " + DateTime.now.to_s,"csv", rand(1..10))
    end

    CSV.open(CSV_FILE, "w") do |csv|
      csv << csv_array.first.keys

      csv_array.each do |hash|
        csv << hash.values
      end
    end
  end

  def create_data(index, datetime, text, origin, rnd)
    { index: index, datetime: datetime, text: text, origin: origin, rnd: rnd }
  end
end
