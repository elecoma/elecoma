# -*- coding: utf-8 -*-
# Ruby 1.9 + gruff-0.3.6 環境での『ZeroDivisionError: divided by 0』エラー対策

require 'gruff'

module Gruff
  class Base
    alias :label_org :label

    # HACK: もとメソッドの下記コードにおいて @marker_count が nil or 0 のとき例外が発生するので、
    #       この条件が揃わないように小細工
    #   label = if (@spread.to_f % @marker_count.to_f == 0) || !@y_axis_increment.nil?
    def label(value)
      marker_count_org = @marker_count
      # 左辺+1を右辺にすることで必ず 0 以外が返る
      @marker_count = @spread.to_f + 1 if @marker_count.to_f.zero?
      result = label_org(value)
      @marker_count = marker_count_org
      result
    end
  end
end
