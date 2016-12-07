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

    def initialize(u, p)
      @url = 'https://apihost1.placesscout.com'
      $auth = 'Basic ' + Base64.encode64(u + ':' + p).chomp      
    end

    def parse_json(response)
      body = JSON.parse(response.to_str) if response.code == 200
      OpenStruct.new(code: response.code, body: body)
    end

# /clients
    def get_clients( opts = {})
        path = "/clients/#{opts[:clientid]}"
        results = []
        params = {}
        params[:page] = opts[:page] || 1
        params[:size] = opts[:size] || MAX_PAGE_SIZE
        total_size = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body['total'] || 1
        total_pages = (opts[:page]) ? 1 : (total_size/params[:size].to_f).ceil  
    
        while total_pages > 0      
          response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body
          results.push(response)
          params[:page] += 1 unless opts[:page]
          total_pages -= 1
        end

        return results
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
      total_size = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body['total'] || 1
      total_pages = (opts[:page]) ? 1 : (total_size/params[:size].to_f).ceil  

      while total_pages > 0
        response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body
        results.push(response)
        params[:page] += 1 unless opts[:page]
        total_pages -= 1
      end
      return results
    end

# /folders
    def get_client_folders( opts = {})
        results = []
        params = {}
        params[:page] = opts[:page] || 1
        params[:size] = opts[:size] || MAX_PAGE_SIZE
        params[:clientid] = opts[:clientid] 
        path =  "/clientfolders"
        total_size = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body['total'] || 1
        total_pages = (opts[:page]) ? 1 : (total_size/params[:size].to_f).ceil  

        while total_pages > 0      
          response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body 
          results.push(response)
          params[:page] += 1 unless opts[:page]
          total_pages -= 1
        end
        return results
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
        keywordserpscreenshot = (opts[:runid] && opts[:runs] && opts[:reportid] && rundates == "" && keywordresults == "" && keywordresultsid == "" && summary == "" && all == "") ? "/keywordserpscreenshot" : ""
        
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
        total_size = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body['total'] || 1
        total_pages = (opts[:page] || opts[:locationid]) ? 1 : (total_size/params[:size].to_f).ceil        
        
        while total_pages > 0  
          response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body
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
      response = parse_json(RestClient.get(@url+path, params: params, :content_type => 'application/json', :accept => 'application/json', :Authorization => $auth)).body
    end





  end

end
