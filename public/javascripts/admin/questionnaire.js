var questions_count = 6;
var question_choices_count = 8;

function fn_choice_display(no, value){
  var question_format = document.getElementsByName('question' + no + '_choice0_format');
  var question_format_length = question_format.length;
  var flag = 0;
  var td;
  for(var i = 0; i < question_format_length; i++) {
    td = document.getElementById("td" + no);
      if ( value == 3 || value == 4 ) {
        td.style.display = 'block';
      } else {
        td.style.display = 'none';
      }
      flag = 1;
    
  }
  if ( flag == 0 ){
    td.style.display = 'none';
  }
}

function fn_display_check_table(){
  for(var i=0; i<questions_count; i++){
    question_format = document.getElementsByName('question' + i + '_choice0_format');
    if (question_format[3].checked == true || question_format[4].checked == true){
      document.getElementById('td' + i).style.display = 'block';
    } else {
      document.getElementById('td' + i).style.display = 'none';
    }
  }
}

function fn_form_clear(){
  document.getElementById('questionnaire_operation_true').checked = false;
  document.getElementById('questionnaire_operation_false').checked = "checked";
  document.getElementById('questionnaire_content').value = "";
  document.getElementById('questionnaire_name').value = "";
  for(var i=0; i<questions_count; i++){
    document.getElementById('questions_' + i).value = "";
    for(var j=0; j<question_choices_count; j++){
      document.getElementById('question' + i + '_choice' + j).value = "";
    }
    for(var k=0; k<5; k++){
      document.getElementById('question' + i + '_choice0_format_' + k).checked = false;
    }
  }
}
