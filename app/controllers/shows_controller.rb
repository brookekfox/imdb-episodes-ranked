class ShowsController < ApplicationController
	def index
		@shows = Show.all
		@base_omdb = 'http://www.omdbapi.com/?'
		@json = '&r=json'
		@base_url = 'http://www.myapifilms.com/imdb?idIMDB='
		@search = '&format=JSON&aka=0&business=0&seasons=1&seasonYear=0&technical=0&lang=en-us&actors=N&biography=0&trailer=0&uniqueName=0&filmography=0&bornDied=0&starSign=0&actorActress=0&actorTrivia=0&movieTrivia=0&awards=0&moviePhotos=N&movieVideos=N'
		@episodes = Array.new
			@title = @shows.last.title.gsub(/\s/,'+')
			# title_array = @shows.last.title.split(' ')
			# @title = title_array.first
			# for i in 1..title_array.length do
			# 	@title = @title + '+' + title_array[i]
			# end
		@omdb_response = HTTParty.get(@base_omdb + 't=' + @title + @json)
		show_id = @omdb_response['imdbID']
		show_info = JSON.parse(HTTParty.get(@base_url + show_id + @search))
		for i in 0..show_info['seasons'].length-1
			for j in 0..show_info['seasons'][i]['episodes'].length-1
				ep_id = show_info['seasons'][i]['episodes'][j]['idIMDB']
				episode_info = HTTParty.get(@base_omdb + 'i=' + ep_id + '&r=json')
				@episodes.push( [ episode_info['Title'], episode_info['Season'].to_i, episode_info['Episode'].to_i, episode_info['imdbRating'].to_f ] )
				j = j + 1
			end
			i = i + 1
		end
		@episodes.sort_by!(&:last).reverse!
	end

	def new
		@show = Show.new
	end

	def create
		@show = Show.create(params.require(:show).permit(:title))
		if @show.save
			redirect_to shows_path
		else
			redirect_to root_path
		end
	end
end
