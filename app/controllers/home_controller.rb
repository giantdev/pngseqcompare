class HomeController < ApplicationController
  def index

  end

  def compare
    ImgseqProcessJob.perform_later(params[:seq1].map{|s1| s1.tempfile.path}, params[:seq2].map{|s2| s2.tempfile.path}, params[:unqid])
    render json: true
  end

  # private

  # def identical? first, second
  #   first.height.times do |y|
  #     first.row(y).each_with_index do |pixel, x|
  #       return false unless pixel == second[x,y]
  #     end
  #   end
  #   return true
  # end
end
