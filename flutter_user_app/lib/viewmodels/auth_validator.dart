mixin AuthValidator {
  String? validateName(String? v) => 
    (v == null || v.trim().isEmpty) ? '이름을 입력해주세요.' : (v.contains(' ') ? '이름에 공백을 포함할 수 없습니다.' : null);
  
  String? validatePhone(String? v) => 
    (v == null || v.isEmpty) ? '휴대전화 번호를 입력해주세요.' : (RegExp(r'^010-\d{4}-\d{4}$').hasMatch(v) ? null : "010으로 시작하는 11자리 숫자를 입력해주세요.");
  
  String? validateEmail(String? v, {required bool isNewUser}) => 
    (!isNewUser) ? null : ((v == null || v.isEmpty) ? '이메일을 입력해주세요.' : (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v) ? null : '유효한 이메일 형식이 아닙니다.'));
  
  String? validateEntryCode(String? v) => 
    (v == null || v.isEmpty) ? '입장코드를 입력해주세요.' : null;
}
