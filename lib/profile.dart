import 'package:flutter/material.dart';
import 'firebase.dart';
import 'global.dart';

bool _reg = false;
bool _reset = false;
String _email = '';
String _password = '';
String _password2 = '';
final _formKey = GlobalKey<FormState>();

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ListView profile() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline_rounded, size: 100),
          minLeadingWidth: 100,
          title: Text(account.email != null ? account.email! : 'Нет почты'),
          minVerticalPadding: 40,
        ),
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: OutlinedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: const Text('ВЫЙТИ', style: TextStyle(fontSize: 15)),
            onPressed: () async {
              final AuthService authService = AuthService();
              await authService.signOut();
              setState(() => account.clear());
            },
          ),
        ),
      ],
    );
  }

  ListView login() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: const Center(
            child: Text(
              'Вход',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                fontFamily: 'BalsamiqSans',
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, top: 30),
          child: const Text(
            'Email',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'BalsamiqSans',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            initialValue: _email,
            decoration: InputDecoration(
              hintText: 'example@mail.com',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(90)),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (String value) => _email = value,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, top: 14),
          child: const Text(
            'Пароль',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'BalsamiqSans',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 30),
          child: TextFormField(
            initialValue: _password,
            decoration: InputDecoration(
              hintText: 'Password123',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(90)),
            ),
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (String value) => _password = value,
          ),
        ),
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            onPressed: () async {
              final AuthService authService = AuthService();
              if (await authService.signEmailPassword(_email, _password)) {
                _email = '';
                _password = '';
                _password2 = '';
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Вход выполнен успешно'),
                ));
                setState(() {});
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Вход не выполнен'),
                ));
              }
            },
            child: const Text('ВОЙТИ', style: TextStyle(fontSize: 15)),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() => _reset = true);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: const Text(
              'Забыли пароль?',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() => _reg = true);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: const Text(
              'Зарегистрироваться',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  ListView registration() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: const Center(
            child: Text(
              'Регистрация',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                fontFamily: 'BalsamiqSans',
              ),
            ),
          ),
        ),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16, top: 30),
                child: const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'BalsamiqSans',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(
                    hintText: 'example@mail.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(90)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (String value) => _email = value,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 14),
                child: const Text(
                  'Пароль',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'BalsamiqSans',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  initialValue: _password,
                  decoration: InputDecoration(
                    hintText: 'Password123',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(90)),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (String value) {
                    setState(() => _password = value);
                  },
                  validator: (value) {
                    if (_password.length < 6) {
                      return 'Пароль должен содержать не менее 6 символов';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 14),
                child: const Text(
                  'Повторите пароль',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'BalsamiqSans',
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 30),
                child: TextFormField(
                  initialValue: _password2,
                  enabled: _password.isNotEmpty,
                  decoration: InputDecoration(
                    hintText: 'Password123',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(90)),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (String value) {
                    _password2 = value;
                  },
                  validator: (value) {
                    if (_password != _password2) return 'Пароли отличаются';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final AuthService authService = AuthService();
                if (await authService.registerEmailPassword(_email, _password)) {
                  _reg = false;
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Регистрация прошла успешно'),
                  ));
                  setState(() {});
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Регистрация не удалась'),
                  ));
                }
              }
            },
            child: const Text('ЗАРЕГИСТРИРОВАТЬСЯ', style: TextStyle(fontSize: 15)),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() => _reg = false);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: const Text(
              'Войти',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  ListView resetPassword() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: const Center(
            child: Text(
              'Сброс пароля',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                fontFamily: 'BalsamiqSans',
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, top: 30),
          child: const Text(
            'Email',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'BalsamiqSans',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            initialValue: _email,
            decoration: InputDecoration(
              hintText: 'example@mail.com',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(90)),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (String value) => _email = value,
          ),
        ),
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            onPressed: () async {
              final AuthService authService = AuthService();
              if (await authService.resetPassword(_email)) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Инструкция выслана на ваш email'),
                ));
                setState(() {});
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Неудача, проверьте ваш email'),
                ));
              }
            },
            child: const Text('ВОССТАНОВИТЬ', style: TextStyle(fontSize: 15)),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() => _reset = false);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: const Text('Войти', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: account.id != null && !_reg
          ? profile()
          : _reg
              ? registration()
              : _reset
                  ? resetPassword()
                  : login(),
    );
  }
}
