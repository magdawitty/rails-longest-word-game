class PagesController < ApplicationController
  def game
    @grid = Array.new(20) { ('A'..'Z').to_a[rand(26)] }
    @grid = @grid.join
  end

  def score
    @start_time = Time.parse(params[:start_time])
    @grid = params[:grid]
    @answer = params[:best_guess]
    @end_time = Time.now
    @game = run_game(@answer, @grid, @start_time, @end_time)
  end


  def included?(guess, grid)
    guess.chars.all? { |letter| guess.chars.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(answer, grid, end_time, start_time)
    result = { time: @end_time - @start_time }

    result[:translation] = get_translation(@answer)
    result[:score], result[:message] = score_and_message(
      @answer, result[:translation], @grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def get_translation(word)
    api_key = "83503067-0e53-436f-8ae0-aa0b4cef28f5"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    end
  end
end


