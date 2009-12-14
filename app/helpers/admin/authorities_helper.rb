module Admin::AuthoritiesHelper
  def to_table(src,cols)
    
    rows = src.size/cols + src.size%cols

    tr_datas = []
    rows.times do |i|
      td_datas = []
      cols.times do |j|
        if (i*cols + j) >= src.size
          break
        end
        td_datas << src[i*cols + j]
      end
      tr_datas << td_datas
    end
    tr_datas
  end
end
