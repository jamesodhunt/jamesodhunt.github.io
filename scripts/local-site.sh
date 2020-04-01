#!/bin/bash
#---------------------------------------------------------------------
# Description: build local copy of GitHub pages site
#---------------------------------------------------------------------

[ -n "$DEBUG" ] && set -x

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_name=${0##*/}

#---------------------------------------------------------------------
# GitHub Pages version of Jekyll
jekyll_image="docker.io/jekyll/jekyll:pages"

site_name="jamesodhunt.github.io"

host="127.0.0.1"
port="4000"

#---------------------------------------------------------------------

die()
{
    msg="$*"
    echo >&2 "ERROR: $msg"
    exit 1
}

info()
{
    str="$*"
    echo "INFO: $str"
}

warn()
{
    str="$*"
    echo >&2 "WARNING: $str"
}

setup()
{
    podman pull "$jekyll_image"
}

copy_site()
{
    local src="$1"

    local site_dir="$2"
    local bundle_dir="$3"

    rm -rf "$site_dir" "$bundle_dir"

    mkdir -p "$site_dir" "$bundle_dir"

    rsync -auvz --exclude=".git" "$src" "${site_dir}/"
    chmod 777 -R "${site_dir}"

    pushd "$site_dir"
    rm -f "Gemfile.lock"
    popd
}

build_and_run_site()
{
    local site_dest="$1"
    local bundle_dest="$2"

    local pkgs=()

    pkgs+=("build-base")
    pkgs+=("gcc")
    pkgs+=("libc-dev")
    pkgs+=("libxml2-dev")
    pkgs+=("libxslt-dev")
    pkgs+=("linux-headers")
    pkgs+=("make")
    pkgs+=("ruby-dev")

    local container_jekyll_dir="/srv/jekyll"
    local container_jekyll_site_dir="${container_jekyll_dir}/$site_name"

    local container_bundle_dir="/usr/local/bundle"

    podman run -it --rm --name jekyll \
        -v "${site_dest}:${container_jekyll_dir}:rw,z" \
        -v "${bundle_dest}:${container_bundle_dir}:rw,z" \
        -w "${container_jekyll_site_dir}" \
        -p "${port}:${port}" \
        "${jekyll_image}" \
        bash -c "apk --no-cache add --virtual build_deps ${pkgs[*]} && \
        bundle install && \
        bundle exec jekyll build --incremental --drafts --config _config.yml,_config-dev.yml && \
        cd ${container_jekyll_site_dir} && \
        bundle exec jekyll serve --drafts --config _config.yml,_config-dev.yml --host ${host} --port ${port}"
}

main()
{
    setup

    local src="$PWD"

    local site_dest="/tmp/site"
    local bundle_dest="/tmp/bundle"

    copy_site "$src" "$site_dest" "$bundle_dest"

    build_and_run_site "$site_dest" "$bundle_dest"
}

main "$@"
