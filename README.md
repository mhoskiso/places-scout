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
opts = {}
opts[:username] = "<username>"
opts[:password] = "<password>"
testcon = PlacesScout::Api.new(opts)
```
### Clients
```ruby
testcon.get_clients()   # Grab all clients. 
testcon.get_clients(:names_and_ids => true) # Just get names and ids
testcon.get_clients(:clientid => 'client-id') #Grab specific client
testcon.create_client(:Name => 'test company',:CustomClientId => 'XXX' , :PrimaryEmail => 'test@test.com', :Website => 'www.test.com')
testcon.update_client(:clientid => 'client-id', :Name => 'test company',:CustomClientId => 'XXX' , :PrimaryEmail => 'test@test.com', :Website => 'www.test.com')
testcon.delete_client(:clientid => 'client-id')
```
### Locations
```ruby
testcon.get_client_locations()   # Grab all client locations. 
testcon.get_client_locations(:clientid => 'client-id') #Grab locations for specific client
testcon.get_client_locations(:locationid => 'location-id') #Grab by location id
```
# Create client location
opts[:clientid] 
opts[:locationid] 
opts[:BusinessName]
opts[:LocationName]
opts[:StreetAddress] 
opts[:StreetAddress2] 
opts[:City] 
opts[:State] 
opts[:Zip] 
opts[:Country]
opts[:Phone] 
opts[:Email] 
opts[:CustomLocationId] 
opts[:Region] 
opts[:StoreNumber]
opts[:PlusLocalPageLink] 
opts[:ListingSites] 
opts[:YextApiKey] 
opts[:YextCustomerId] 
opts[:YextLocationId] 
opts[:LocationGroupId] 
```ruby
opts = {}
opts[:clientid] = '<client-id>'
opts[:LocationName] = "Location Name"
puts testcon.create_client_location(opts)
```
# Delete client location
```ruby
 opts = {}
 opts[:LocationId] = '<location-id>'
 puts testcon.delete_client_location(opts)
```
### Folders
```ruby
testcon.get_client_folders()#Grab all client folders.
testcon.get_client_folders(:clientid => 'client-id') #Grab folder off client id
```
### Rank Reports
# GET /rankingreports
All rank reports, or for client or location
```ruby
opts = {}
``` 
  Optional
  opts[:locationid] = '<location-id>' <-- Doesn't restrict results, might not be working on API end
  opts[:clientid] = '<client-id>'
```ruby
puts testcon.get_ranking_reports(opts)
```

# GET /rankingreports/{clientId}/allbyclient
All rank reports for client
```ruby
opts = {}
opts[:clientid] = '<client-id>'
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}
Returns the ranking report configuration data for the given RankingReportId
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/historical
Returns historical data that can be used to display charts over time for the given RankingReportId
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:historical] = true
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/historical/keywords
Returns historical data for each keyword search that can be used to display charts over time for the given RankingReportId
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:historical] = true
opts[:keywords] = true
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/rundatesandids
Returns report run ids and dates
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:rundatesandids] = true
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/runs
Returns all runs of a report
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:runs] = true
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/runs/{reportRunId}
Returns a ranking report run based on the passed ReportRunId
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:reportRunId] = '<report-run-id>'
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/runs/{reportRunId}/keywordsearchresults
Returns a list of all keyword search results for a given ranking report run
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:reportRunId] = '<report-run-id>'
opts[:keywordsearchresults] = true
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/runs/{reportRunId}/keywordsearchresults/{keywordSearchResultsId}
Returns a list of all keyword search results for a given ranking report run
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:reportRunId] = '<report-run-id>'
opts[:keywordsearchresults] = true
opts[:KeywordSearchResultsId] = '<report-run-id>-surgery-for-adhesions-san-luis-obispo-ca'
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/runs/{reportRunId}/keywordserpscreenshot
Returns a byte array of image data for the first Google Organic SERP Page for the provided ReportId, reportRunId, keyword, and location setting if the ranking report is configured to gather screenshots
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:reportRunId] = '<report-run-id>'
opts[:keywordsearchresults] = true
opts[:GoogleLocation] = ''
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/runs/{reportRunId}/summarymetrics
Returns the ranking summary metrics for the passed ReportRunId
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:reportRunId] = '<report-run-id>'
opts[:summarymetrics] = true
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/{ReportId}/runs/newest
Returns the newest runs of a report
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
opts[:age] = "oldest" || "newest"
puts testcon.get_ranking_reports(opts)
```
# GET /rankingreports/all
Retrieving all ranking report data
```ruby
opts = {}
opts[:all] = true
puts testcon.get_ranking_reports(opts)
```
# POST /rankingreports/{ReportId}/runreport
Run a ranking report
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
puts testcon.run_ranking_report(opts)
```

# DELETE /rankingreports/{ReportId}
```ruby
opts = {}
opts[:ReportId] = '<report-id>'
puts testcon.delete_ranking_report(opts)
```

###Reputation Reports
 ```ruby
 opts = {}
 opts[:clientid] = '<client-id>'
 opts[:ReportId] = '<report-id>'
 opts[:reportRunId] = '<report-run-id>'
 opts[:historical] = true
 opts[:newreviews] = true
 opts[:reviews] = true
 opts[:source] = "Yelp"
 opts[:rundatesandids] = true
 opts[:runs] = true
puts testcon.get_reputation_reports(opts)
 ```

## POST /reputationreports/{reportId}/runreport
 Runs the passed reputation report, placing the request in the queue to run the report
  ```ruby
 opts = {}
 opts[:ReportId] = '<report-id>'
 opts[:FullScrape] = true
 puts testcon.run_reputation_report(opts)
 ```

## Delete Reputation Report or Reputation Report Run
 Pass a report id to delete the report and all runs, add a run id to only delete that run.
  ```ruby
 opts = {}
 opts[:ReportId] = '<report-id>'
 opts[:ReportRunId] = '<report-run-id>'
 puts testcon.delete_reputation_report(opts)
 ```


###Combined Reports
# GET /combinedclientreports
 All rank reports, or for client or location
```ruby
opts = {}
opts[:clientid] = '<client-id>' 
puts testcon.get_combined_reports(opts)
```
### Status
```ruby
testcon.get_status #Grab the status of all reports
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhoskiso/places_scout.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

