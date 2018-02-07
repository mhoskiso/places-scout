require 'bundler/setup'
require "places_scout/version"
require "base64"
require 'json'
require 'ostruct'

require 'rest-client'

module PlacesScout
  class Api
  # RestClient.log = 'stdout' #Debugging API calls
    MAX_PAGE_SIZE = '100'

    def initialize(opts = {})
      @url = 'https://apihost1.placesscout.com'
      @auth = 'Basic ' + Base64.encode64(opts[:username] + ':' + opts[:password]).chomp      
    end

    def parse_json(response)
      body = JSON.parse(response.to_str) if response.code == 200 || response.code == 201
      OpenStruct.new(code: response.code, body: body)
    end

    def set_params(opts = {})
      params = {}
      #Result params
        params[:size] = opts[:size] || MAX_PAGE_SIZE
        params[:path] = opts[:path] if opts[:path]
        params[:page] = opts[:page] || 1
      #Client params
        params[:Name] = opts[:Name] if opts[:Name]  #String
        params[:CustomClientId] = opts[:CustomClientId] if opts[:CustomClientId] #String
        params[:PrimaryEmail] = opts[:PrimaryEmail] if opts[:PrimaryEmail] #String
        params[:Website] = opts[:Website] if opts[:Website] #String
        params[:Industry] = opts[:Industry] if opts[:Industry]  #String
        params[:Categories] = opts[:Categories] if opts[:Categories] #List
        params[:GoogleAccountId] = opts[:GoogleAccountId] if opts[:GoogleAccountId] #String
        params[:GoogleWebPropertyId] = opts[:GoogleWebPropertyId] if opts[:GoogleWebPropertyId] #String
        params[:GoogleProfileId] = opts[:GoogleProfileId] if opts[:GoogleProfileId]  #String
        params[:GoogleAnalyticsReportSections] = opts[:GoogleAnalyticsReportSections] if opts[:GoogleAnalyticsReportSections] #List
      #Location params
        params[:clientid] = opts[:clientid] if opts[:clientid]
        params[:locationid] = opts[:locationid] if opts[:locationid]
      #Ranking Reports
        params[:Keyword] = opts[:keywordserpscreenshot] if opts[:keywordserpscreenshot]
        params[:GoogleLocation] = opts[:googlelocation] if opts[:googlelocation]
      #Reputation Reports
        params[:FullScrape] = opts[:FullScrape] if opts[:FullScrape]
     

      return params
    end

    def get_responses(opts = {})
      responses = []
      params = set_params(opts)
      response = parse_json(RestClient.get(@url+opts[:path], params: params,:content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body
      
      total_records = response["total"] || 1
      size = response["size"] || 1
      total_pages = (total_records.to_f/size).ceil || 1             

      while total_pages > 0
        response = (opts[:data]) ? response[opts[:data]] : response 
        responses.push(response)
        params[:page] += 1 unless opts[:page]
        total_pages -= 1     
        response = parse_json(RestClient.get(@url+params[:path], params: params,:content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body unless total_pages < 1            
      end

      return responses.flatten! || responses
    end

# /clients
    def get_clients( opts = {})
        opts[:path] = "/clients/#{opts[:clientid] || ((opts[:names_and_ids]) ? "namesandids" : "")}"
        opts[:data] = "items" unless opts[:clientid]       
        return get_responses(opts) 
    end

    def create_client( opts = {})
        params = set_params(opts)
        path = "/clients"
        response = parse_json(RestClient.post(@url+path, params ,:content_type => 'application/json', :accept => 'application/json', :Authorization => @auth))
        return response 
    end

    def update_client( opts = {})
        params = set_params(opts)
        path = "/clients/#{opts[:clientid]}"
        return parse_json(RestClient.put(@url+path, params,:content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body 
    end

    def delete_client ( opts = {} )
      if opts[:clientid]
        path = "/clients/#{opts[:clientid]}"
        return RestClient.delete(@url+path, :Authorization => @auth)
      else
        return "Must pass client id"
      end
    end

# Client Locations
    def get_client_locations( opts = {})
      opts[:path] = "/clientlocations/#{opts[:locationid]}"
      opts[:data] = "items" unless opts[:locationid]   
      return get_responses(opts) 
    end

    def create_client_location( opts = {})

    end

# /folders
    def get_client_folders( opts = {})  
      opts[:path] =  "/clientfolders"
      opts[:data] = "items"
      return get_responses(opts) 
    end

# /rankingreports
      def get_ranking_reports( opts = {})

        opts[:path] = "/rankingreports/"

        if opts[:clientid]
          opts[:path] += "#{opts[:clientid]}/allbyclient"
        elsif opts[:reportid]
          opts[:path] += "#{opts[:reportid]}/"
            if opts[:historical]
              opts[:path] += "historical"
              opts[:path] += "/keywords" if opts[:keywords]
            elsif  opts[:rundatesandids]
              opts[:path] += "rundatesandids"
            elsif opts[:runs] || opts[:reportRunId]
              opts[:path] += "runs"
              if opts[:reportRunId]
                opts[:path] += "/#{opts[:reportRunId]}"
                opts[:path] += "/keywordsearchresults" if opts[:keywordsearchresults]
                opts[:path] += "/#{opts[:KeywordSearchResultsId]}" if opts[:KeywordSearchResultsId]
                opts[:path] += "/summarymetrics" if opts[:summarymetrics]
              end
            end 
        else
          opts[:path] += "all"
        end
  
        opts[:data] = "items" unless (opts[:reportid] && opts[:rundatesandids].nil? && opts[:keywordsearchresults].nil?) || opts[:KeywordSearchResultsId]

        return get_responses(opts)            
    end

    def run_ranking_report( opts = {})
      path = "/rankingreports/#{opts[:reportid]}/runreport"
      params = {:ReportID => opts[:reportid]}
      response = RestClient.post(@url+path, params ,:content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)
      return response 
    end

    def delete_ranking_report ( opts = {} )
      path = "/rankingreports/#{opts[:reportid]}"
      path += "/runs/#{opts[:reportRunId]}" if opts[:reportRunId]
      return RestClient.delete(@url+path, :Authorization => @auth)   
    end

    #Reputation Reports

    def get_reputation_reports ( opts = {})
      opts[:path] = "/reputationreports/"

      if opts[:clientid]
       opts[:path] += "#{opts[:clientid]}/allbyclient"
      elsif opts[:reportid]
        opts[:path] += "#{opts[:reportid]}/"
          if opts[:historical]
            opts[:path] += "historical"
          elsif opts[:newreviews]
            opts[:path] += "newreviews" 
          elsif opts[:reviews] || opts[:source] 
            opts[:path] += "reviews" 
            opts[:path] += "/#{opts[:source]}"if opts[:source] 
          elsif  opts[:rundatesandids]
            opts[:path] += "rundatesandids" 
          elsif opts[:runs] || opts[:reportRunId]
            opts[:path] += "runs"
            opts[:path] += "/#{opts[:reportRunId]}" if opts[:reportRunId]
            opts[:path] += "/newest" if opts[:newest]
            opts[:path] += "/oldest" if opts[:oldest]
          end

      else
        opts[:path] += "all"
      end

      opts[:data] = "items" unless (opts[:reportid] && opts[:reviews].nil? && opts[:rundatesandids].nil?)
      return get_responses(opts) 

    end

    def run_reputation_report( opts = {})
      path = "/reputationreports/#{opts[:reportid]}/runreport"
      params = {:ReportID => opts[:reportid], :FullScrape => opts[:FullScrape] }
      response = RestClient.post(@url+path, params ,:content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)
      return response 
    end

    def delete_reputation_report ( opts = {} )
      path = "/reputationreports/#{opts[:reportid]}"
      path += "/runs/#{opts[:reportRunId]}" if opts[:reportRunId]
      return RestClient.delete(@url+path, :Authorization => @auth)   
    end

    def get_status( opts = {})
      results = []
      params = {}
      reportid = "/#{opts[:reportid]}" || ""
      path = "/status/getreportstatus"
      response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body
    end





  end

end
