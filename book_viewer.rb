require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?


before do
  @contents = File.readlines('data/toc.txt')
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def strong_select(text, term)
    text.gsub(term, "<strong>" + term + "</strong>")
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"  
  erb :home
end

get "/chapters/:number" do 
  number = params[:number].to_i
  redirect '/' if number > @contents.size
  chapter_name = @contents[number - 1]

  @chapter = File.read("data/chp#{number}.txt")
  @title = "Chapter #{number}: #{chapter_name}"
  erb :chapter
end

get "/search" do
  if params[:query]
    @results = @contents.each_with_index.each_with_object([]) do |(chapter, index), results|
      text = File.read("data/chp#{index + 1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |paragraph, paragraph_index|
        if paragraph.include?(params[:query])
          results << [chapter, index, strong_select(paragraph, params[:query]), paragraph_index]
        end
      end
    end
  end
  erb :search
end

get "/show/:name" do
  params[:name]
end

