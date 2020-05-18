#!/bin/bash

if [ -z "$ROUTE_ALGO" ]
then
    ROUTE_ALGO=mld
fi

DATA_DIR=$(dirname $ROUTE_DATA)
DATA=$(basename $ROUTE_DATA)
DATA_STEM="${DATA%%.*}"
echo "Dir: "
echo $DATA_DIR
echo "Stem: "
echo $DATA_STEM

if [ -z "$ROUTE_DATA" ] || [ -z "$ROUTE_TYPE" ]
then
    echo "No route data specified. Please set \$ROUTE_DATA and \$ROUTE_TYPE"
    exit 1
elif [ -f $DATA_DIR/$DATA_STEM.osrm ]
then
    DATA_STEM = $(basename $ROUTE_DATA)
    osrm-routed --algorithm mld "$DATA_DIR/$DATA_STEM.osrm"
elif [ -f "$ROUTE_DATA" ]
then
    osrm-extract -p "/opt/$ROUTE_TYPE.lua" "$ROUTE_DATA"
    osrm-partition "$DATA_DIR/$DATA_STEM.osrm"
    osrm-customize "$DATA_DIR/$DATA_STEM.osrm"
fi
