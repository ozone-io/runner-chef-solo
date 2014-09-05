#!/bin/sh

#Downloads chef install script and executes it with parameters supplied

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

#solaris2 has wget on a different path
if test -f "/etc/release"; then
  PATH=/usr/sfw/bin:$PATH
  export PATH
fi

# do_wget URL FILENAME
do_wget() {
  echo "Trying wget..."
  wget -O "$2" "$1" 2>/tmp/stderr
  rc=$?

  # check for 404
  grep "ERROR 404" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "wget"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_curl() {
  echo "Trying curl..."
  curl -1 -sL -D /tmp/stderr "$1" > "$2"
  rc=$?
  # check for 404
  grep "404 Not Found" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "404 for $1"
    return 1
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "curl"
    return 1
  fi

  return 0
}

# do_fetch URL FILENAME
do_fetch() {
  echo "Trying fetch..."
  fetch -o "$2" "$1" 2>/tmp/stderr
  # check for bad return status
  test $? -ne 0 && return 1
  return 0
}

# do_perl URL FILENAME
do_perl() {
  echo "Trying perl..."
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "$1" > "$2" 2>/tmp/stderr
  rc=$?
  # check for 404
  grep "404 Not Found" /tmp/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "404 for $1"
    return 1
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "perl"
    return 1
  fi

  return 0
}

# do_download URL FILENAME
do_download() {
  echo "Downloading $1 to $2"

  # we try all of these until we get success.
  # perl, in particular may be present but LWP::Simple may not be installed

  if exists wget; then
    do_wget $1 $2 && return 0
  fi

  if exists curl; then
    do_curl $1 $2 && return 0
  fi

  if exists fetch; then
    do_fetch $1 $2 && return 0
  fi

  if exists perl; then
    do_perl $1 $2 && return 0
  fi

  echo "Could not download file. No download methods available."
  exit 1
}

capture_tmp_stderr() {
  # spool up /tmp/stderr from all the commands we called
  if test -f "/tmp/stderr"; then
    output=`cat /tmp/stderr`
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n$output\n"
    rm /tmp/stderr
  fi
}

#############
#  Installs chef 
#############

echo "installing chef"
if [ "x$CHEF_ALWAYS_INSTALL_CHEF" = "xtrue" ] || ! chef-solo --version >/dev/null 2>&1; then
  echo "chef not detected or installation is forced"
  do_download "$CHEF_INSTALL_SCRIPT" "chef-solo-install.sh"
  sh "./chef-solo-install.sh" "$CHEF_INSTALL_SCRIPT_ARGS" || exit 1
  echo "finished chef install script"
else
  echo "-- chef-solo found. skipping chef installation."
fi
