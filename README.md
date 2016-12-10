# PlacesScout

A gem to interact with the Places Scout API. https://www.placesscout.com/api
Check the usage section for what's currently implemented.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'places_scout'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install places_scout

## Usage

You can add :size & :page as parameters to grab specific size/page to the calls below. The maximum size supported by the API is 100.
```ruby
get_ranking_reports() # Defaults to returning all pages with 100 results each
get_ranking_reports(:size => '10') # Returns all pages with 10 results each
get_ranking_reports(:size => '5', page => '5') # Returns only the 5th page
```
### Connecting to the API
```ruby
testcon = PlacesScout::Api.new("username", "password")
```
### Clients
```ruby
testcon.get_clients()   # Grab all clients. 
testcon.get_clients(:clientid => 'client-id') #Grab specific client
```
### Locations
```ruby
testcon.get_client_locations()   # Grab all client locations. 
testcon.get_client_locations(:clientid => 'client-id') #Grab locations for specific client
testcon.get_client_locations(:locationid => 'location-id') #Grab by location id
```
### Folders
```ruby
testcon.get_client_folders()#Grab all client folders.
testcon.get_client_folders(:clientid => 'client-id') #Grab folder off client id
```
### Rank Reports
```ruby
testcon.get_ranking_reports #Grab a list of all ranking reports. 
testcon.get_ranking_reports(:all => true) #Grab all ranking report data. 
testcon.get_ranking_reports(:clientid => 'client-id') #Grab Rank reports for a specific client
testcon.get_ranking_reports(:clientid => 'client-id', :locationid=> 'location-id') # Grab specific location for specific client
testcon.get_ranking_reports(:reportid => 'report-id') #Grab a specific ranking report
testcon.get_ranking_reports(:reportid => 'report-id', :historical => true) #Return chart for average rankings over time 
testcon.get_ranking_reports(:reportid => 'report-id', :historical => true, :keywords => true) #Return chart for keyword rankings over time
testcon.get_ranking_reports(:reportid => 'report-id', :rundates => true) # Return run dates and ID's for a report
testcon.get_ranking_reports(:reportid => 'report-id', :runs => true) #Grab the runs for a report
testcon.get_ranking_reports(:reportid => 'report-id', :runs => true, :runid => 'run-id') #Grab a specific report run
testcon.get_ranking_reports(:reportid => 'report-id', :runs => true, :runid => 'run-id', :keywordresults => true) #Grab a specific report run keyword results
testcon.get_ranking_reports(:reportid => 'report-id', :runs => true, :runid => 'run-id', :keywordresults => true, :keywordresultsid => 'keyword-results-id') #Grab a specific keyword result for a specific report run 
testcon.get_ranking_reports(:reportid => 'report-id', :runs => true, :runid => 'run-id', :keywordserpscreenshot => 'adhesion treatment' , :googlelocation => 'San Luis Obispo, CA') #Google Organic SERP Page
testcon.get_ranking_reports(:reportid => 'report-id', :runs => true, :runid => 'run-id', :summary => true) # Grab summary metrics
testcon.get_ranking_reports(:reportid => 'report-id', :runs => true, :newest => true) # Grab newest if :newest => true. Grab oldest if :newest => false
```

### Status
```ruby
testcon.get_status #Grab the status of all reports
```
## Sample Code
```ruby
clients = get_clients_and_ids(testcon) #Grab all clients
add_report_ids(clients, testcon) #Grab report ID's per client
add_report_run_ids(clients, testcon) # Grab run  per report
get_run_rankings(clients, testcon) # Grab results per run
puts clients[0][:reports][0][:runs][0][:rankings][0] # Return first client, report, run, keyword ranks


def get_clients_and_ids(testcon)
    clients = []
    results = testcon.get_clients()  

    results.each do |result|
        result['items'].each do |item|
          clients.push(:name => item['name'], :id => item['id'])
        end
    end

    return clients
end

def add_report_ids(clients, testcon)
    clients.each do |client|
        report_ids = []
        rankings = testcon.get_ranking_reports(:clientid => client[:id])
        rankings.each do |rank|
            rank['items'].each do |item|
                report_ids.push(:id => item['rankingReport']['id']) 
            end
        end
        client[:reports] = report_ids
    end
    return clients
end

def add_report_run_ids(clients, testcon)
    clients.each do |client|
        run_id_date = []
        client[:reports].each do |report|
            report_runs = testcon.get_ranking_reports(:reportid => report[:id], :rundates => true)
                report_runs.each do |runs|
                    runs['items'].each do |run|
                        run_id_date.push(:runID => run['runId'], :runDate => parse_date(run['runDate']))
                    end
                end
             report[:runs] = run_id_date
        end
    end
end

def get_run_rankings(clients, testcon)
    clients.each do |client|
        client[:reports].each do |report|            
            report[:runs].each do |run|
            keyword_rankings = []
                report_runs = testcon.get_ranking_reports(:reportid => report[:id], :runs => true, :runid => run[:runID])
                    report_runs.each do |report_run|
                        report_run['keywordRankingResults'].each do |results|
                            results[1].each do |result|
                                google_rankings = []
                                bing_rankings = []
                                result['keywordSearch']['keyword']

                                result['googleOrganicRankings'].each do |g_rank|
                                    google_rankings.push(g_rank['rank'])
                                end

                                result['bingOrganicRankings'].each do |b_rank|
                                    bing_rankings.push(b_rank['rank'])
                                end

                                keyword_rankings.push(:keyword => result['keywordSearch']['keyword'], :google_rank => google_rankings, :bing_rank => bing_rankings)

                            end
                        end
                    end
                run[:rankings] = keyword_rankings
            end
        end
    end
end


def parse_date(datestring)
  seconds_since_epoch = datestring.scan(/[0-9]+/)[0].to_i / 1000.0
  return Time.at(seconds_since_epoch)
end

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhoskiso/places_scout.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

