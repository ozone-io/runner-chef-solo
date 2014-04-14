#!/bin/sh

error () {
 echo "Failure in install"
 exit 1
}
trap error SIGHUP SIGINT SIGTERM ERR

# Timestamp
now () {
    date +'%H:%M:%S %z'
}

# Logging functions instead of echo
log () {
    echo "`now` ${1}"
}

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# Random function since not all shells have $RANDOM
random () {
    hexdump -n 2 -e '/2 "%u"' /dev/urandom
}

#solaris2 has wget on a different path
if test -f "/etc/release"; then
  PATH=/usr/sfw/bin:$PATH
  export PATH
fi

#create stderr for reading out errors in downloaders
OZONE_TMP_STDERR="$TMPDIR/ozone/stderr.$$.`random`"

# do_wget URL FILENAME
do_wget() {
  log "Trying wget..."
  wget -O "$2" "$1" 2>"$OZONE_TMP_STDERR"
  rc=$?

  # check for 404
  grep "ERROR 404" "$OZONE_TMP_STDERR" 2>&1 >/dev/null
  if test $? -eq 0; then
    log "ERROR 404"
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
  log "Trying curl..."
  curl -1 -sL -D "$OZONE_TMP_STDERR" "$1" > "$2"
  rc=$?
  # check for 404
  grep "404 Not Found" "$OZONE_TMP_STDERR" 2>&1 >/dev/null
  if test $? -eq 0; then
    log "404 for $1"
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
  log "Trying fetch..."
  fetch -o "$2" "$1" 2>"$OZONE_TMP_STDERR"
  # check for bad return status
  test $? -ne 0 && return 1
  return 0
}

# do_perl URL FILENAME
do_perl() {
  log "Trying perl..."
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "$1" > "$2" 2>$OZONE_TMP_STDERR
  rc=$?
  # check for 404
  grep "404 Not Found" "$OZONE_TMP_STDERR" 2>&1 >/dev/null
  if test $? -eq 0; then
    log "404 for $1"
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
  log "Downloading $1 to $2"

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

  log "Could not download file. No download methods available."
  exit 1
}

capture_tmp_stderr() {
  # spool up tmp_stderr from all the commands we called
  if test -f "$OZONE_TMP_STDERR"; then
    output=`cat ${OZONE_TMP_STDERR}`
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n$output\n"
    rm "$OZONE_TMP_STDERR"
  fi
}

#############
#  Installs chef solo
# * Is a bootstrapping stage: Only installs packages so that chef-solo is available. Does nothing else.
#############

log "installing chef"
if [ "x$CHEF_ALWAYS_INSTALL_CHEF" = "xtrue" ] || ! chef-solo --version >/dev/null 2>&1; then
  log "chef not detected or installation is forced"
  # download chef install script $CHEF_INSTALL_SCRIPT to $OZONE_TMP_DIR/chef-solo-install.sh
  do_download "$CHEF_INSTALL_SCRIPT" "$OZONE_TMP_DIR/chef-solo-install.sh"
  sh "$OZONE_TMP_DIR/chef-solo-install.sh" "$CHEF_INSTALL_SCRIPT_ARGS"
  log "finished chef install script"
else
  log "-- chef-solo found. skipping chef installation."
fi
