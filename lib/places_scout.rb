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
        opts[:path] = "/clients/#{opts[:clientid]}"
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
      path = "/clientlocations/#{opts[:locationid]}"
      results = []
      params = {}
      params[:page] = opts[:page] || 1
      params[:size] = opts[:size] || MAX_PAGE_SIZE
      params[:clientid] = opts[:clientid]
      location = opts[:locationid]
      # total_size = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body['total'] || 1
      # total_pages = (opts[:page]) ? 1 : (total_size/params[:size].to_f).ceil  

      # while total_pages > 0
      #   response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body
      #   results.push(response)
      #   params[:page] += 1 unless opts[:page]
      #   total_pages -= 1
      # end
      # return results
    end

# /folders
    def get_client_folders( opts = {})
        results = []
        params = {}
        params[:page] = opts[:page] || 1
        params[:size] = opts[:size] || MAX_PAGE_SIZE
        params[:clientid] = opts[:clientid] 
        path =  "/clientfolders"
        # total_size = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body['total'] || 1
        # total_pages = (opts[:page]) ? 1 : (total_size/params[:size].to_f).ceil  

        # while total_pages > 0      
        #   response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body 
        #   results.push(response)
        #   params[:page] += 1 unless opts[:page]
        #   total_pages -= 1
        # end
        # return results
    end

# /rankingreports
      def get_ranking_reports( opts = {})
        results = []
        params = {}
        reportid = "/#{opts[:reportid]}" || ""
        params[:locationid] = opts[:locationid] || ""
        params[:clientid] = opts[:clientid] || ""
        all = (opts[:all]) ? "/all" : ""
        historical = (opts[:historical] && opts[:reportid] && all == "") ? "/historical" : ""
        keywords = (opts[:historical] && opts[:reportid] && opts[:keywords] && all == "") ? "/keywords" : ""
        rundates = (opts[:rundates] && opts[:reportid] && all == "") ? "/rundatesandids" : ""
        runs = (opts[:runs] && opts[:reportid] && rundates == "" && all == "") ? "/runs" : ""
        runid = (opts[:runid] && opts[:runs] && rundates == "" && all == "") ? "/#{opts[:runid]}" : ""
        summary = (opts[:summary] && opts[:runid] && opts[:runs] && rundates == "" && all == "") ? "/summarymetrics" : ""
        keywordresults = (opts[:keywordresults] && opts[:runid] && opts[:runs] && opts[:reportid] && rundates =="" && summary == "" && all == "") ? "/keywordsearchresults" : ""
        keywordresultsid = (opts[:keywordresultsid] && opts[:keywordresults] && opts[:runid] && opts[:runs] && opts[:reportid] && rundates =="" && summary == "" && all == "") ? "/#{opts[:keywordresultsid]}" : ""
        keywordserpscreenshot = (opts[:runid] && opts[:runs] && opts[:reportid] && opts[:googlelocation] && rundates == "" && keywordresults == "" && keywordresultsid == "" && summary == "" && all == "") ? "/keywordserpscreenshot" : ""
        
        newest = case opts[:newest]
                  when opts[:newest] = true  
                      "/newest"
                  when opts[:newest] = false
                      "/oldest"
                  else
                      ""
                 end

        path = (opts[:clientid] && params[:locationid] == "" && all == "") ? "/rankingreports/#{opts[:clientid]}/allbyclient" : "/rankingreports#{all}#{reportid}#{rundates}#{runs}#{newest}#{runid}#{summary}#{historical}#{keywords}#{keywordresults}#{keywordresultsid}#{keywordserpscreenshot}"     
        params[:Keyword] = opts[:keywordserpscreenshot] if opts[:keywordserpscreenshot]
        params[:GoogleLocation] = opts[:googlelocation] if opts[:googlelocation]
        params[:page] = opts[:page] || 1
        params[:size] = opts[:size] || MAX_PAGE_SIZE
        total_size = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body['total'] || 1
        total_pages = (opts[:page] || opts[:locationid]) ? 1 : (total_size/params[:size].to_f).ceil        
        
        while total_pages > 0  
          response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => @auth)).body
          results.push(response)
          params[:page] += 1 unless opts[:page]
          total_pages -= 1
        end
        return results     
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
