function fnUpdateActivity(id, activity){
  new Ajax.Request('/admin/admin_users/update_activity?id='+id+'&activity='+activity, { "method": "post",
              onSuccess: function(request) {
              },
              onFailure: function(request) { alert("管理ユーザーの更新に失敗しました");
              }
  });
}

