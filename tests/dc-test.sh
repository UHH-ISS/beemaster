sudo sysctl -w vm.max_map_count=262144
docker-compose -f dc-testing.yml down -v
docker-compose -f dc-testing.yml up --build 
