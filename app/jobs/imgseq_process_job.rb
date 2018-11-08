require 'chunky_png'
require 'phashion'

class ImgseqProcessJob < ApplicationJob
  queue_as :default

  def perform(pseq1, pseq2, uniqid)
    total = pseq2.length
    iden = 0
    index1 = 0
    img2 = []

    ActionCable.server.broadcast "progress_channel_#{uniqid}",
                                  iden:  iden,
                                  total:  total,
                                  progress: 0,
                                  progressTotal: pseq1.length,
                                  status: 'preparing...'

    pseq2.each do |seq2_file|
      img2.push Phashion::Image.new(seq2_file)
    end

    pseq1.each do |seq1_file|
      imgRotate = ChunkyPNG::Image.from_file(seq1_file).flip_vertically.save("#{seq1_file}_")
      img1 = Phashion::Image.new(seq1_file)
      img1_r = Phashion::Image.new("#{seq1_file}_")

      index1 += 1
      puts "-------------#{index1}---------------"
      img2.each_with_index do |i2, index2|
        if img1.duplicate?(i2, :threshold => 0) || img1_r.duplicate?(i2, :threshold => 0)
          puts "#{index1} and #{index2 + 1} are same!"
          iden += 1
          break
        end
      end

      ActionCable.server.broadcast "progress_channel_#{uniqid}",
                                  iden:  iden,
                                  total:  total,
                                  progress: index1,
                                  progressTotal: pseq1.length,
                                  status: 'in progress'
    end

    ActionCable.server.broadcast "progress_channel_#{uniqid}",
                                  iden:  iden,
                                  total:  total,
                                  progress: pseq1.length,
                                  progressTotal: pseq1.length,
                                  status: 'finished!'
  end
end
