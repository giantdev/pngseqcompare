require 'chunky_png'
require 'phashion'

class HomeController < ApplicationController
  def index

  end

  def compare
    total = params[:seq2].length
    iden = 0
    index1 = 0
    img2 = []

    ActionCable.server.broadcast "progress_channel_#{params[:unqid]}",
                                  iden:  iden,
                                  total:  total,
                                  progress: 0,
                                  progressTotal: params[:seq1].length,
                                  status: 'preparing...'

    params[:seq2].each do |seq2_file|
      img2.push Phashion::Image.new(seq2_file.tempfile.path)
    end

    params[:seq1].each do |seq1_file|
      imgRotate = ChunkyPNG::Image.from_file(seq1_file.tempfile).flip_vertically.save("#{seq1_file.tempfile.path}_")
      img1 = Phashion::Image.new(seq1_file.tempfile.path)
      img1_r = Phashion::Image.new("#{seq1_file.tempfile.path}_")

      index1 += 1
      puts "-------------#{index1}---------------"
      img2.each_with_index do |i2, index2|
        if img1.duplicate?(i2, :threshold => 0) || img1_r.duplicate?(i2, :threshold => 0)
          puts "#{index1} and #{index2 + 1} are same!"
          iden += 1
          break
        end
      end

      ActionCable.server.broadcast "progress_channel_#{params[:unqid]}",
                                  iden:  iden,
                                  total:  total,
                                  progress: index1,
                                  progressTotal: params[:seq1].length,
                                  status: 'in progress'
    end

    ActionCable.server.broadcast "progress_channel_#{params[:unqid]}",
                                  iden:  iden,
                                  total:  total,
                                  progress: params[:seq1].length,
                                  progressTotal: params[:seq1].length,
                                  status: 'finished!'

    render json: {identical: iden, unique: total - iden}
  end

  private

  def identical? first, second
    first.height.times do |y|
      first.row(y).each_with_index do |pixel, x|
        return false unless pixel == second[x,y]
      end
    end
    return true
  end
end
