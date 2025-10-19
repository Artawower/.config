function docker-clean
    docker image prune -a
    docker system prune -a --volumes
end
