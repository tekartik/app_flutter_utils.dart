import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_common_utils/bool_utils.dart';

//  "TRAVIS": "true",
//  "TRAVIS_DART_VERSION": "stable",

bool get runningOnTravis => parseBool(Platform.environment['TRAVIS']) == true;

String get travisDartVersion =>
    Platform.environment['TRAVIS_DART_VERSION'] ?? 'stable';

String get travisFlutterTop =>
    '${userHomePath}/.tekartik/travis/${travisDartVersion}/flutter';

/// Create the envir file
Future<String> travisCreateEnvFile() async {
  Directory tempDir = await Directory.systemTemp.createTemp();

  const String envRc = "env.rc";

  String content = '''
    
export PATH=${travisFlutterTop}/bin:${travisFlutterTop}/bin/cache/dart-sdk/bin:\$PATH

''';

  File dst = File(join(tempDir.path, envRc));
  await dst.writeAsString(content, flush: true);
  return dst.path;
}

Future main() async {
  var shell = Shell();

  //print(jsonPretty(Platform.environment));
  //  "TRAVIS_DART_VERSION": "stable",

  print('dartVersion: $travisDartVersion');
  print('flutterTop: $travisFlutterTop');

  //TODO
  bool install = true; //!runningOnTravis;

  await Directory(dirname(travisFlutterTop)).create(recursive: true);

  if (install) {
    // update
    if (File(join(travisFlutterTop, '.git')).existsSync()) {
      await shell.run('''
      
      git pull
      
      ''');
    } else {
      // install

      await shell.run('''
    
# ls $travisFlutterTop
git clone https://github.com/flutter/flutter.git --depth 1 ${travisFlutterTop} -b ${travisDartVersion}

''');
    }
    await shell.run('''
$travisFlutterTop/bin/flutter doctor
''');
  }
  var path = await travisCreateEnvFile();
  print('env_file: $path');
  print(await File(path).readAsString());
}

// {
//  "TRAVIS_DART_ANALYZE": "false",
//  "MANPATH": "/home/travis/.nvm/versions/node/v6.12.0/share/man:/home/travis/.kiex/elixirs/elixir-1.3.2/man:/home/travis/.rvm/rubies/ruby-2.4.1/share/man:/usr/local/man:/usr/local/cmake-3.9.2/man:/usr/local/clang-5.0.0/share/man:/usr/local/share/man:/usr/share/man:/home/travis/.rvm/man",
//  "TRAVIS_ARCH": "amd64",
//  "XDG_SESSION_ID": "2",
//  "MYSQL_UNIX_PORT": "/var/run/mysqld/mysqld.sock",
//  "rvm_bin_path": "/home/travis/.rvm/bin",
//  "HAS_JOSH_K_SEAL_OF_APPROVAL": "true",
//  "PYENV_ROOT": "/opt/pyenv",
//  "NVM_CD_FLAGS": "",
//  "GEM_HOME": "/home/travis/.rvm/gems/ruby-2.4.1",
//  "TRAVIS_STACK_JOB_BOARD_REGISTER": "/.job-board-register.yml",
//  "TRAVIS_TEST_RESULT": "",
//  "TRAVIS_STACK_LANGUAGES": "__amethyst__ crystal csharp d dart elixir erlang haskell haxe julia perl perl6 r rust",
//  "SHELL": "/bin/bash",
//  "TERM": "xterm",
//  "HISTSIZE": "1000",
//  "ELIXIR_VERSION": "1.3.2",
//  "IRBRC": "/home/travis/.rvm/rubies/ruby-2.4.1/.irbrc",
//  "SSH_CLIENT": "10.10.19.218 57942 22",
//  "TRAVIS_COMMIT": "3eb3f8e2a6feefda00a62a470ed9e3e077eeff38",
//  "TRAVIS_OS_NAME": "linux",
//  "TRAVIS_APT_PROXY": "http://build-cache.travisci.net",
//  "TRAVIS_JOB_NAME": "",
//  "TRAVIS_UID": "2000",
//  "TRAVIS_INTERNAL_RUBY_REGEX": "^ruby-(2\\.[0-4]\\.[0-9]|1\\.9\\.3)",
//  "OLDPWD": "/home/travis/build",
//  "MY_RUBY_HOME": "/home/travis/.rvm/rubies/ruby-2.4.1",
//  "TRAVIS_ROOT": "/",
//  "SSH_TTY": "/dev/pts/0",
//  "TRAVIS_TIMER_ID": "0721e407",
//  "LC_ALL": "en_US.UTF-8",
//  "MIX_ARCHIVES": "/home/travis/.kiex/mix/elixir-1.3.2",
//  "ANSI_GREEN": "\\033[32;1m",
//  "NVM_DIR": "/home/travis/.nvm",
//  "HISTFILESIZE": "2000",
//  "USER": "travis",
//  "PUB_ENVIRONMENT": "travis",
//  "_system_type": "Linux",
//  "TRAVIS_LANGUAGE": "dart",
//  "TRAVIS_INFRA": "gce",
//  "PERLBREW_BASHRC_VERSION": "0.80",
//  "ANSI_RESET": "\\033[0m",
//  "rvm_path": "/home/travis/.rvm",
//  "TRAVIS_GHC_ROOT": "/opt/ghc",
//  "TRAVIS_DIST": "trusty",
//  "TRAVIS": "true",
//  "TRAVIS_REPO_SLUG": "tekartik/app_flutter_utils.dart",
//  "ANSI_YELLOW": "\\033[33;1m",
//  "HAS_ANTARES_THREE_LITTLE_FRONZIES_BADGE": "true",
//  "PYTHON_CONFIGURE_OPTS": "--enable-unicode=ucs4 --with-wide-unicode --enable-shared --enable-ipv6 --enable-loadable-sqlite-extensions --with-computed-gotos",
//  "TRAVIS_BUILD_STAGE_NAME": "",
//  "TRAVIS_COMMIT_MESSAGE": "test: travis",
//  "TRAVIS_PULL_REQUEST": "false",
//  "PAGER": "cat",
//  "RACK_ENV": "test",
//  "TRAVIS_CMD": "dart tool/travis_flutter_install.dart",
//  "PERLBREW_ROOT": "/home/travis/perl5/perlbrew",
//  "TRAVIS_STACK_TIMESTAMP": "2017-12-05 21:12:24 UTC",
//  "rvm_prefix": "/home/travis",
//  "PYTHON_CFLAGS": "-g -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security",
//  "PATH": "/home/travis/.pub-cache/bin:/home/travis/dart-sdk/bin:/home/travis/bin:/home/travis/.local/bin:/opt/pyenv/shims:/home/travis/.phpenv/shims:/home/travis/perl5/perlbrew/bin:/home/travis/.nvm/versions/node/v6.12.0/bin:/home/travis/.kiex/elixirs/elixir-1.3.2/bin:/home/travis/.kiex/bin:/home/travis/.rvm/gems/ruby-2.4.1/bin:/home/travis/.rvm/gems/ruby-2.4.1@global/bin:/home/travis/.rvm/rubies/ruby-2.4.1/bin:/home/travis/gopath/bin:/home/travis/.gimme/versions/go1.7.4.linux.amd64/bin:/usr/local/phantomjs/bin:/usr/local/phantomjs:/usr/local/neo4j-3.2.7/bin:/usr/local/cmake-3.9.2/bin:/usr/local/clang-5.0.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ghc/bin:/home/travis/.rvm/bin:/home/travis/.phpenv/bin:/opt/pyenv/bin:/home/travis/.yarn/bin",
//  "MAIL": "/var/mail/travis",
//  "TRAVIS_PULL_REQUEST_SHA": "",
//  "TRAVIS_OSX_IMAGE": "",
//  "TRAVIS_JOB_WEB_URL": "https://travis-ci.org/tekartik/app_flutter_utils.dart/jobs/498300117",
//  "TRAVIS_TMPDIR": "/tmp/tmp.a8sqIqKkWj",
//  "TRAVIS_BUILD_WEB_URL": "https://travis-ci.org/tekartik/app_flutter_utils.dart/builds/498300116",
//  "PWD": "/home/travis/build/tekartik/app_flutter_utils.dart",
//  "JAVA_HOME": "/usr/lib/jvm/java-8-oracle",
//  "CONTINUOUS_INTEGRATION": "true",
//  "LANG": "en_US.UTF-8",
//  "TRAVIS_PRE_CHEF_BOOTSTRAP_TIME": "2017-12-05T21:12:11",
//  "DART_SDK": "/home/travis/dart-sdk",
//  "MERB_ENV": "test",
//  "TZ": "UTC",
//  "TRAVIS_CABAL_ROOT": "/opt/cabal",
//  "PERLBREW_HOME": "/home/travis/.perlbrew",
//  "_system_arch": "x86_64",
//  "TRAVIS_DART_TEST": "true",
//  "PS1": "${debian_chroot:+($debian_chroot)}\\u@\\h:\\w\\$ ",
//  "TRAVIS_ENABLE_INFRA_DETECTION": "true",
//  "TRAVIS_SUDO": "true",
//  "_system_version": "14.04",
//  "TRAVIS_CABAL_DEFAULT": "1.24",
//  "TRAVIS_TAG": "",
//  "TRAVIS_ALLOW_FAILURE": "false",
//  "RBENV_SHELL": "bash",
//  "HISTCONTROL": "ignoredups:ignorespace",
//  "TRAVIS_HOME": "/home/travis",
//  "TRAVIS_INIT": "upstart",
//  "rvm_version": "1.29.3 (latest)",
//  "TRAVIS_GHC_DEFAULT": "8.0.2",
//  "TRAVIS_JOB_NUMBER": "2.1",
//  "TRAVIS_EVENT_TYPE": "push",
//  "PYENV_SHELL": "bash",
//  "PS4": "+",
//  "HOME": "/home/travis",
//  "SHLVL": "2",
//  "GOROOT": "/home/travis/.gimme/versions/go1.7.4.linux.amd64",
//  "ANSI_CLEAR": "\\033[0K",
//  "RAILS_ENV": "test",
//  "TRAVIS_DART_VERSION": "stable",
//  "TRAVIS_TIMER_START_TIME": "1551118260649865470",
//  "CI": "true",
//  "TRAVIS_BUILD_ID": "498300116",
//  "LOGNAME": "travis",
//  "TRAVIS_STACK_FEATURES": "basic cassandra chromium couchdb disabled-ipv6 docker docker-compose elasticsearch firefox go-toolchain google-chrome jdk memcached mongodb mysql neo4j nodejs_interpreter perl_interpreter perlbrew phantomjs postgresql python_interpreter rabbitmq redis riak ruby_interpreter sqlite xserver",
//  "TRAVIS_DART_FORMAT": "false",
//  "TRAVIS_PULL_REQUEST_SLUG": "",
//  "COMPOSER_NO_INTERACTION": "1",
//  "GEM_PATH": "/home/travis/.rvm/gems/ruby-2.4.1:/home/travis/.rvm/gems/ruby-2.4.1@global",
//  "SSH_CONNECTION": "10.10.19.218 57942 10.20.0.104 22",
//  "LC_CTYPE": "en_US.UTF-8",
//  "TRAVIS_SECURE_ENV_VARS": "false",
//  "DEBIAN_FRONTEND": "noninteractive",
//  "NVM_BIN": "/home/travis/.nvm/versions/node/v6.12.0/bin",
//  "GOPATH": "/home/travis/gopath",
//  "TRAVIS_STACK_NODE_ATTRIBUTES": "/.node-attributes.yml",
//  "TRAVIS_STACK_NAME": "amethyst",
//  "TRAVIS_APP_HOST": "build.travis-ci.org",
//  "GIT_ASKPASS": "echo",
//  "TRAVIS_BRANCH": "dart2",
//  "XDG_RUNTIME_DIR": "/run/user/2000",
//  "TRAVIS_COMMIT_RANGE": "a5a1a2cc5065...3eb3f8e2a6fe",
//  "JRUBY_OPTS": " --client -J-XX:+TieredCompilation -J-XX:TieredStopAtLevel=1 -J-Xss2m -Xcompile.invokedynamic=false",
//  "JDK_SWITCHER_DEFAULT": "oraclejdk8",
//  "TRAVIS_PULL_REQUEST_BRANCH": "",
//  "TRAVIS_JOB_ID": "498300117",
//  "ANSI_RED": "\\033[31;1m",
//  "RUBY_VERSION": "ruby-2.4.1",
//  "TRAVIS_BUILD_NUMBER": "2",
//  "_system_name": "Ubuntu",
//  "TRAVIS_BUILD_DIR": "/home/travis/build/tekartik/app_flutter_utils.dart",
//  "_": "/home/travis/dart-sdk/bin/dart",
//  "GLIBCPP_FORCE_NEW": "1",
//  "GLIBCXX_FORCE_NEW": "1"
//}
