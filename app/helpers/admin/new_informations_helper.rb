# -*- coding: utf-8 -*-
module Admin::NewInformationsHelper
  def new_window(flg)
    if flg
      "別ウィンドウで開く"
    else
      "同じウィンドウで開く"
    end
  end
end
