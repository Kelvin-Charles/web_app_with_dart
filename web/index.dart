import 'dart:html';
import 'dart:convert';

void main() {
  final usernameInput = querySelector('#username') as InputElement;
  final passwordInput = querySelector('#password') as InputElement;
  final loginButton = querySelector('#loginButton') as ButtonElement;

  loginButton.onClick.listen((event) async {
    var username = usernameInput.value!;
    var password = passwordInput.value!;

    var url = 'http://localhost:8081/authenticate';
   var response = await HttpRequest.request(
      url,
  method: 'POST',
  requestHeaders: {'Content-Type': 'application/json'},
  sendData: json.encode({
    'username': username,
    'password': password,
  }),
    );

    var result = jsonDecode(response.responseText!);
    if (result['status'] == 'success') {
      window.alert('Login successful!');
    } else {
      window.alert('Login failed!');
    }
  });
}
