#!/bin/bash
set -e
arguments="$*"
echo "arguments : $arguments"

# Reset all variables that might be set
USE_TRAINING_UAA=0
CUSTOM_UAA_INSTANCE=""
RUN_DELETE_SERVICES=0
RUN_CREATE_SERVICES=0
RUN_CREATE_ACS=0
RUN_CREATE_ANALYTIC_FRAMEWORK=0
RUN_CREATE_ASSET=0
RUN_CREATE_TIMESERIES=0
RUN_CREATE_UAA=0
RUN_CREATE_ASSET_MODEL_DEVICE1=0
RUN_CREATE_ASSET_MODEL_RMD=0
RUN_MACHINE_CONFIG=0
RUN_COMPILE_REPO=0
RUN_MACHINE_TRANSFER=0
RUN_PRINT_VARIABLES=0
SKIP_SERVICES=0
RUN_CREATE_MACHINE_CONTAINER=0
USE_WINDDATA_SERVICE=0
USE_DATAEXCHANGE=0
USE_WEBSOCKET_SERVER=0
USE_DATA_SIMULATOR=0
USE_RMD_DATASOURCE=0
USE_NODEJS_STARTER=0
USE_NODEJS_STARTER_W_TIMESERIES=0
USE_POLYMER_SEED=0
USE_POLYMER_SEED_UAA=0
USE_POLYMER_SEED_ASSET=0
USE_POLYMER_SEED_TIMESERIES=0
USE_POLYMER_SEED_RMD=0
USE_DATAEXCHANGE_UI=0
MACHINE_CONTAINER_TYPE="Debug"

function __print_out_usage
{
	echo -e "Usage:\n"
	echo -e "./$SCRIPT_NAME [ options ]\n"

  echo -e "Build Basic App options are as below"
  echo "[-release| --release-version]               => Release version of the repositories if using released version"
  echo "services:"
  echo "[-acs|     --create-acs]                    => Create the access control service instance"
  echo "[-af|      --create-analytic-framework]     => Create the analytic framework service instance"
  echo "[-asset|   --create-asset]                  => Create the asset service instance"
  echo "[-ts|      --create-timeseries]             => Create the time series service instance"
  echo "[-tu|      --training-uaa]                  => Use a Training UAA Instance. Default does not use the Training UAA instance"
  echo "[-uaa|     --create-uaa]                    => Create the uaa service instance"
  echo "asset-model:"
  echo "[-amd1|     --create-asset-model-device1]   => Create the access model for device1"
  echo "[-amrmd|    --create-asset-model-rmd]       => Create the access model for remote monitoring and diagnostics"
  echo "back-end:"
  echo "[-dx|      --data-exchange]                  => Use data-exchange as backend"
  echo "[-rmd|     --rmd-datasource]                => Use rmd-datasource as backend"
  echo "[-sim|     --data-simulator]                => Use data-exchange-simulator as backend"
  echo "[-wd|      --wind-data]                     => Use winddata-timeseries-service as backend"
  echo "[-wss|     --websocket-server]              => Use websocket-server as backend"
  echo "front-end:"
	echo "[-ns| 		 --nodejs-starter]            	  => Install the build-a-basic nodejs express front-end web app to visualize the data"
	echo "[-nsts| 	 --nodejs-starter-w-timeseries]   => Install the build-a-basic nodejs express front-end web app to visualize the data, plus UAA, Asset, Time Series"
  echo "[-ps|       --polymer-seed]                 => Install the build-a-basic polymer-seed front-end web app driven by json files to visualize the data"
  echo "[-psuaa|    --polymer-seed-uaa]             => Install the build-a-basic polymer-seed front-end web app with UAA to visualize the data"
  echo "[-psasset|  --polymer-seed-asset]           => Install the build-a-basic polymer-seed front-end web app with Asset and UAA to visualize the data"
  echo "[-psts|     --polymer-seed-timeseries]      => Install the build-a-basic polymer-seed front-end web app with Time Series and UAA to visualize the data"
  echo "[-psrmd|    --polymer-seed-rmd-refapp]      => Install the build-a-basic polymer-seed front-end web app with UAA, Asset, Timeseries, Websocket Server, Data Exchange, Data Simulator, and RMD Datasource to visualize the data"
  echo "[-dxui|     --data-exchange-ui]             => Install the rmd-ref-app data-exchange-ui front-end web app to visualize the saved data sets"
  echo "machine:"
  echo "[-mc|      --machine-config]                => Configure machine container with valid endpoints to UAA and Time Series"
  echo "[-mt|      --machine-transfer]              => Transfer the configured Machine container to desired device"



	echo -e "*** examples\n"
	echo -e "./$SCRIPT_NAME -uaa -asset -ts              => install services"
	echo -e "./$SCRIPT_NAME -uaa -asset -ts -nodestarter => only services and front-end app deployed"
	echo -e "./$SCRIPT_NAME -uaa -asset -ts -mc          => only services deployed and predix machine configured"
	echo -e "./$SCRIPT_NAME -uaa -asset -ts -mc -cc -mt  => create services, machine config, compile repos and transfer machine container"
}

#process all the switches as normal
while :; do
		case $1 in
        -tu|--training-uaa)
          USE_TRAINING_UAA=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-tu | --training-uaa"
          PRINT_USAGE=0
          ;;
        -custom-uaa)
          if [ -n "$2" ]; then
              CUSTOM_UAA_INSTANCE=$2
              SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-custom-uaa"
              PRINT_USAGE=0
              shift
          else
              printf 'ERROR: "-custom-uaa" requires a non-empty option argument.\n' >&2
              exit 1
          fi
          ;;
        -ds|--delete-services)
          RUN_DELETE_SERVICES=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-ds | --delete-services"
          PRINT_USAGE=0
          ;;
        -cs|--create-services) #deprecated
          RUN_CREATE_SERVICES=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-cs | --create-services"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -uaa|--create-uaa)
          RUN_CREATE_UAA=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-uaa | --create-uaa"
					SWITCH_ARRAY[SWITCH_INDEX++]="-uaa"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -acs|--create-acs)
          RUN_CREATE_ACS=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-acs | --create-acs"
					SWITCH_ARRAY[SWITCH_INDEX++]="-acs"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -af|--create-analytic-framework)
          RUN_CREATE_ANALYTIC_FRAMEWORK=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-af | --create-analytic-framework"
					SWITCH_ARRAY[SWITCH_INDEX++]="-af"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -acs|--create-acs)
          RUN_CREATE_ACS=1
					SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-acs|--create-acs"
					SWITCH_ARRAY[SWITCH_INDEX++]="-acs"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -asset|--create-asset)
          RUN_CREATE_ASSET=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-asset | --create-asset"
					SWITCH_ARRAY[SWITCH_INDEX++]="-asset"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -ts|--create-timeseries)
          RUN_CREATE_TIMESERIES=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-ts | --create-timeseries"
					SWITCH_ARRAY[SWITCH_INDEX++]="-ts"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -amd1|--create-asset-model-device1)
          RUN_CREATE_ASSET_MODEL_DEVICE1=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-amd1 | --create-asset-model-device1"
					SWITCH_ARRAY[SWITCH_INDEX++]="-amd1"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -amrmd|--create-asset-model-rmd)
            if [ -n "$2" ]; then
								RUN_CREATE_ASSET_MODEL_RMD=1
                RUN_CREATE_ASSET_MODEL_RMD_METADATA_FILE=$2
                SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-amrmd | --create-asset-model-rmd"
								SWITCH_ARRAY[SWITCH_INDEX++]="-amrmd"
                PRINT_USAGE=0
                LOGIN=1
                shift
                if [ -n "$2" ]; then
                  RUN_CREATE_ASSET_MODEL_RMD_FILE=$2
                  shift
                fi
            else
                printf 'ERROR: "-amrmd" requires a 2 non-empty option arguments. One for Metadata File, One for AssetModel File\n' >&2
                exit 1
            fi
						;;
        -mc|--machine-config)
          RUN_MACHINE_CONFIG=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-mc | --machine-config"
					SWITCH_ARRAY[SWITCH_INDEX++]="-mc"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -cc|--clean-compile)
          RUN_COMPILE_REPO=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-cc | --clean-compile"
          PRINT_USAGE=0
          VERIFY_MVN=1
          ;;
        -mt|--machine-transfer)
          RUN_MACHINE_TRANSFER=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-mt | --machine-transfer"
					SWITCH_ARRAY[SWITCH_INDEX++]="-mt"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -cm|--create-machine)
          RUN_CREATE_MACHINE_CONTAINER=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-cm | --create-machine"
					SWITCH_ARRAY[SWITCH_INDEX++]="-cm"
          PRINT_USAGE=0
          VERIFY_MVN=1
          LOGIN=0
          ;;
        -machine-container-type)
          if [ -n "$2" ]; then
            if [[ $2 =~ ^("Agent"|"Agent_Debug"|"Prov"|"Debug"|"Tech"|"Conn"|"Custom"|"AGENT"|"AGENT_DEBUG"|"PROV"|"DEBUG"|"TECH"|"CONN"|"CUSTOM")$ ]]; then
              MACHINE_CONTAINER_TYPE=$2
            else
              printf 'ERROR: "machine-container-type" requires a argument[AGENT|AGENT_DEBUG|PROV|DEBUG|TECH|CONN|CUSTOM].\n' >&2
              exit 1
            fi
            shift
          else
            printf 'ERROR: "machine-container-type" requires a argument[AGENT|AGENT_DEBUG|PROV|DEBUG|TECH|CONN|CUSTOM].\n' >&2
            exit 1
          fi
          ;;
        -machine-version)
          if [ -n "$2" ]; then
            MACHINE_VERSION=$2
            shift
          else
            printf 'ERROR: "-release| -machine-version" requires a non-empty option argument.\n' >&2
            exit 1
          fi
          ;;
        -em|--edge-manager)
          RUN_EDGE_MANAGER_SETUP=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-em | --edge-manager"
					SWITCH_ARRAY[SWITCH_INDEX++]="-em"
          PRINT_USAGE=0
          ;;
        -if|--install-frontend) #deprecated
          USE_NODEJS_STARTER_W_TIMESERIES=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-if | --install-frontend"
          PRINT_USAGE=0
          LOGIN=1
          ;;
				-ns|--nodejs-starter)
          USE_NODEJS_STARTER=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-nodestarter | --nodejs-starter"
					SWITCH_ARRAY[SWITCH_INDEX++]="-nodestarter"
          PRINT_USAGE=0
          LOGIN=1
          ;;
				-nsts|--nodejs-starter-w-timeseries)
          USE_NODEJS_STARTER_W_TIMESERIES=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-nsts | --nodejs-starter-w-timeseries"
					SWITCH_ARRAY[SWITCH_INDEX++]="-nsts"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -ps|--polymer-seed)
          USE_POLYMER_SEED=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-ps | --polymer-seed"
					SWITCH_ARRAY[SWITCH_INDEX++]="-ps"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -psuaa|--polymer-seed-uaa)
          USE_POLYMER_SEED_UAA=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-psuaa | --polymer-seed-uaa"
					SWITCH_ARRAY[SWITCH_INDEX++]="-psuaa"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -psasset|--polymer-seed-asset)
          USE_POLYMER_SEED_ASSET=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-psasset | --polymer-seed-asset"
					SWITCH_ARRAY[SWITCH_INDEX++]="-paasset"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -psts|--polymer-seed-timeseries)
          USE_POLYMER_SEED_TIMESERIES=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-psts | --polymer-seed-timeseries"
					SWITCH_ARRAY[SWITCH_INDEX++]="-psts"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -psrmd|--polymer-seed-rmd-refapp)
          USE_POLYMER_SEED_RMD=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-psrmd | --polymer-seed-rmd-refapp"
					SWITCH_ARRAY[SWITCH_INDEX++]="-psrmd"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -dxui|--data-exchange-ui)
          USE_DATAEXCHANGE_UI=1
          SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-dxui | --data-exchange-ui"
					SWITCH_ARRAY[SWITCH_INDEX++]="-dxui"
          PRINT_USAGE=0
          LOGIN=1
          ;;
        -wd|--wind-data)       # Takes an option argument, ensuring it has been specified.
            USE_WINDDATA_SERVICE=1
            SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-wd | --wind-data"
						SWITCH_ARRAY[SWITCH_INDEX++]="-wd"
            PRINT_USAGE=0
            VERIFY_MVN=1
            LOGIN=1
          ;;
        -dx|--data-exchange)       # Takes an option argument, ensuring it has been specified.
            USE_DATAEXCHANGE=1
            SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-dx | --data-exchange"
						SWITCH_ARRAY[SWITCH_INDEX++]="-dx"
            PRINT_USAGE=0
            VERIFY_MVN=1
            LOGIN=1
          ;;
        -wss|--websocket-server)       # Takes an option argument, ensuring it has been specified.
            USE_WEBSOCKET_SERVER=1
            SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-wss | --websocket-server"
						SWITCH_ARRAY[SWITCH_INDEX++]="-wss"
            PRINT_USAGE=0
            VERIFY_MVN=1
            LOGIN=1
          ;;
        -sim|--data-simulator)       # Takes an option argument, ensuring it has been specified.
            USE_DATA_SIMULATOR=1
            SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-sim | --data-simulator"
						SWITCH_ARRAY[SWITCH_INDEX++]="-sim"
            PRINT_USAGE=0
            VERIFY_MVN=1
            LOGIN=1
          ;;
        -rmd|--rmd-datasource)       # Takes an option argument, ensuring it has been specified.
            USE_RMD_DATASOURCE=1
            SWITCH_DESC_ARRAY[SWITCH_DESC_INDEX++]="-rmd | --rmd-datasource"
						SWITCH_ARRAY[SWITCH_INDEX++]="-rmd"
            PRINT_USAGE=0
            VERIFY_MVN=1
            LOGIN=1
          ;;
				-predix-machine-home)
					if [ -n "$2" ]; then
						PREDIX_MACHINE_HOME=$2
						shift
					else
						printf 'ERROR: "-predix-machine-home" requires a non-empty option argument.\n' >&2
						exit 1
					fi
					;;
        --)              # End of all options.
					shift
					break
          ;;
        -?*)
					doShift=0
					processSwitchCommon $@
					if [[ $doShift == 1 ]]; then
						shift
					fi
          ;;
				*)               # Default case: If no more options then break out of the loop.
          break
					;;
    esac
  	shift
done

#echo "Switches=${SWITCH_DESC_ARRAY[*]}"

if [[ ($RUN_CREATE_MACHINE_CONTAINER == 1) && (! -n $MACHINE_VERSION) ]]; then
  __error_exit "-cm|--create-machine requires option -machine-version to be set " "$quickstartLogDir"
fi

if [[ "$MACHINE_VERSION" == "" ]]; then
	MACHINE_VERSION="16.4.2"
fi
PREDIX_MACHINE_HOME=""$rootDir/PredixMachine$MACHINE_CONTAINER_TYPE


if [[ "$RUN_PRINT_VARIABLES" == "0" ]]; then
	printCommonVariables
  echo ""
  echo "SERVICES:"
  echo "CUSTOM_UAA_INSTANCE                      : $CUSTOM_UAA_INSTANCE"
  echo "RUN_CREATE_SERVICES                      : $RUN_CREATE_SERVICES"
  echo "RUN_CREATE_ACS                           : $RUN_CREATE_ACS"
  echo "RUN_CREATE_ASSET                         : $RUN_CREATE_ASSET"
  echo "RUN_CREATE_TIMESERIES                    : $RUN_CREATE_TIMESERIES"
  echo "USE_TRAINING_UAA                         : $USE_TRAINING_UAA"
  echo "RUN_CREATE_UAA                           : $RUN_CREATE_UAA"
  echo ""
  echo "ASSET-MODEL:"
  echo "RUN_CREATE_ASSET_MODEL_DEVICE1           : $RUN_CREATE_ASSET_MODEL_DEVICE1"
  echo "RUN_CREATE_ASSET_MODEL_RMD               : $RUN_CREATE_ASSET_MODEL_RMD"
  echo "RUN_CREATE_ASSET_MODEL_RMD_METADATA_FILE : $RUN_CREATE_ASSET_MODEL_RMD_METADATA_FILE"
  echo "RUN_CREATE_ASSET_MODEL_RMD_FILE          : $RUN_CREATE_ASSET_MODEL_RMD_FILE"
  echo ""
  echo "BACK-END:"
  echo "USE_DATAEXCHANGE                         : $USE_DATAEXCHANGE"
  echo "USE_DATA_SIMULATOR                       : $USE_DATA_SIMULATOR"
  echo "USE_RMD_DATASOURCE                       : $USE_RMD_DATASOURCE"
  echo "USE_WEBSOCKET_SERVER                     : $USE_WEBSOCKET_SERVER"
  echo "USE_WINDDATA_SERVICE                     : $USE_WINDDATA_SERVICE"
  echo ""
  echo "FRONT-END:"
	echo "USE_NODEJS_STARTER                       : $USE_NODEJS_STARTER"
	echo "USE_NODEJS_STARTER_W_TIMESERIES          : $USE_NODEJS_STARTER_W_TIMESERIES"
  echo "USE_POLYMER_SEED                         : $USE_POLYMER_SEED"
  echo "USE_POLYMER_SEED_UAA                     : $USE_POLYMER_SEED_UAA"
  echo "USE_POLYMER_SEED_ASSET                   : $USE_POLYMER_SEED_ASSET"
  echo "USE_POLYMER_SEED_TIMESERIES              : $USE_POLYMER_SEED_TIMESERIES"
  echo "USE_POLYMER_SEED_RMD                     : $USE_POLYMER_SEED_RMD"
  echo "USE_DATAEXCHANGE_UI                      : $USE_DATAEXCHANGE_UI"
  echo ""
  echo "MACHINE:"
  echo "PREDIX_MACHINE_HOME			 : $PREDIX_MACHINE_HOME"
  echo "RUN_MACHINE_CONFIG                       : $RUN_MACHINE_CONFIG"
  echo "RUN_CREATE_MACHINE_CONTAINER             : $RUN_CREATE_MACHINE_CONTAINER"
  echo "RUN_EDGE_MANAGER_SETUP                   : $RUN_EDGE_MANAGER_SETUP"
  echo "MACHINE_VERSION                          : $MACHINE_VERSION"
  echo "MACHINE_CONTAINER_TYPE                   : $MACHINE_CONTAINER_TYPE"
  echo "RUN_MACHINE_TRANSFER                     : $RUN_MACHINE_TRANSFER"
  echo ""
fi

export CUSTOM_UAA_INSTANCE
export USE_TRAINING_UAA
export RUN_DELETE_SERVICES
export RUN_CREATE_SERVICES
export RUN_CREATE_ACS
export RUN_CREATE_ANALYTIC_FRAMEWORK
export RUN_CREATE_ASSET
export RUN_CREATE_ASSET_MODEL_DEVICE1
export RUN_CREATE_ASSET_MODEL_RMD
export RUN_CREATE_ASSET_MODEL_RMD_FILE
export RUN_CREATE_ASSET_MODEL_RMD_METADATA_FILE
export RUN_CREATE_TIMESERIES
export RUN_CREATE_UAA
export RUN_MACHINE_CONFIG
export RUN_CREATE_MACHINE_CONTAINER
export RUN_COMPILE_REPO
export RUN_EDGE_MANAGER_SETUP
export RUN_MACHINE_TRANSFER
export USE_WINDDATA_SERVICE
export USE_DATAEXCHANGE
export USE_WEBSOCKET_SERVER
export USE_DATA_SIMULATOR
export USE_RMD_DATASOURCE
export USE_NODEJS_STARTER
export USE_NODEJS_STARTER_W_TIMESERIES
export USE_POLYMER_SEED
export USE_POLYMER_SEED_UAA
export USE_POLYMER_SEED_ASSET
export USE_POLYMER_SEED_TIMESERIES
export USE_POLYMER_SEED_RMD
export USE_DATAEXCHANGE_UI
export PREDIX_MACHINE_HOME
export MACHINE_CONTAINER_TYPE
export MACHINE_VERSION
export ENDPOINT

exportCommonVariables
#	----------------------------------------------------------------
#	Function for creating an asset with metadata
#		Accepts 3 arguments:
#			string of Directory to which to clone
#			string indicating whether to not remove directory
#  Returns:
#	----------------------------------------------------------------
function runFunctionForBasicApp() {
	while :; do
		runFunctionForCommon $1 $2
	    case $2 in
					-h|--help)
						__print_out_usage
						break
						;;
	        -uaa|--create-uaa)
						break
	          ;;
	        -acs|--create-acs)
						break
	          ;;
	        -af|--create-analytic-framework)
						break
						;;
	        -acs|--create-acs)
	          break
						;;
	        -af|--create-analytic-framework)
	          break
						;;
	        -asset|--create-asset)
	          break
						;;
	        -ts|--create-timeseries)
						break
						;;
	        -amd1|--create-asset-model-device1)
						source "$rootDir/bash/scripts/build-basic-app-asset-model.sh"
						getPredixAssetInfo $1

						if [[ ( $RUN_CREATE_ASSET_MODEL_DEVICE1 == 1 ) ]]; then
							assetModelDevice1 $1
						fi
	          break
						;;
	        -amrmd|--create-asset-model-rmd)
						source "$rootDir/bash/scripts/build-basic-app-asset-model.sh"
						getPredixAssetInfo $1
						if [[ ( $RUN_CREATE_ASSET_MODEL_RMD == 1 ) ]]; then
							assetModelRMD $1
						fi
	          break
						;;
	        -mc|--machine-config)
						# Build Predix Machine container using properties from Predix Services Created above
					  if [[ $RUN_MACHINE_CONFIG -eq 1 ]] || [[ $RUN_MACHINE_TRANSFER -eq 1 ]]; then
					    __echo_run  "$rootDir/bash/scripts/predix_machine_setup.sh" "$TEMP_APP" "$RUN_MACHINE_CONFIG" "$RUN_MACHINE_TRANSFER"
					  fi
	          break
						;;
	        -mt|--machine-transfer)
	          break
						;;
	        -cm|--create-machine)
						if [[ $RUN_CREATE_MACHINE_CONTAINER -eq 1 ]]; then
							source "$rootDir/bash/scripts/create_machine_container.sh"
							create_machine_container-main
						fi
	          break
						;;
	        -em|--edge-manager)
	          break
						;;
					-nodestarter|--nodejs-starter)
						if [[ $USE_NODEJS_STARTER -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-nodejs.sh"
					    build-basic-app-nodejs-main $1
					  fi
	          break
						;;
					-nsts|--nodejs-starter-w-timeseries)
						if [[ $USE_NODEJS_STARTER_W_TIMESERIES -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-nodejs-w-timeseries.sh"
					    build-basic-app-nodejs-w-timeseries-main $1
					  fi
	          break
						;;
	        -ps|--polymer-seed)
						if [[ $USE_POLYMER_SEED -eq 1 ]]; then
							source "$rootDir/bash/scripts/build-basic-app-polymerseed.sh"
							build-basic-app-polymerseed-main $1
						fi
						break
						;;
	        -psuaa|--polymer-seed-uaa)
						if [[ $USE_POLYMER_SEED_UAA -eq 1 ]]; then
							source "$rootDir/bash/scripts/build-basic-app-polymerseed-uaa.sh"
							build-basic-app-polymerseed-uaa-main $1
						fi
	          break
						;;
	        -psasset|--polymer-seed-asset)
						if [[ $USE_POLYMER_SEED_ASSET -eq 1 ]]; then
							source "$rootDir/bash/scripts/build-basic-app-polymerseed-asset.sh"
							build-basic-app-polymerseed-asset-main $1
						fi
	          break
						;;
	        -psts|--polymer-seed-timeseries)
						if [[ $USE_POLYMER_SEED_TIMESERIES -eq 1 ]]; then
							source "$rootDir/bash/scripts/build-basic-app-polymerseed-timeseries.sh"
							build-basic-app-polymerseed-timeseries-main $1
						fi
	          break
						;;
	        -psrmd|--polymer-seed-rmd-refapp)
						if [[ $USE_POLYMER_SEED_RMD -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-polymerseed-rmd.sh"
					    build-basic-app-polymerseed-rmd-main $1
					  fi
	          break
						;;
	        -dxui|--data-exchange-ui)
						if [[ $USE_DATAEXCHANGE_UI -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-dataexchange-ui.sh"
					    build-basic-app-dataexchange-ui-main $1
					  fi
	          break
						;;
	        -wd|--wind-data)       # Takes an option argument, ensuring it has been specified.
						if [[ $USE_WINDDATA_SERVICE -eq 1 ]]; then
							source "$rootDir/bash/scripts/build-basic-app-winddata.sh"
							build-basic-app-winddata-main $1
						fi
	          break
						;;
	        -dx|--data-exchange)       # Takes an option argument, ensuring it has been specified.
						if [[ $USE_DATAEXCHANGE -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-dataexchange.sh"
					    build-basic-app-dataexchange-main $1
					  fi
	          break
						;;
	        -wss|--websocket-server)       # Takes an option argument, ensuring it has been specified.
						if [[ $USE_WEBSOCKET_SERVER -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-websocketserver.sh"
					    build-basic-app-websocketserver-main $1
					  fi
	          break
						;;
	        -sim|--data-simulator)       # Takes an option argument, ensuring it has been specified.
						if [[ $USE_DATA_SIMULATOR -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-data-simulator.sh"
					    build-basic-app-data-simulator-main $1
					  fi
	          break
						;;
	        -rmd|--rmd-datasource)       # Takes an option argument, ensuring it has been specified.
						if [[ $USE_RMD_DATASOURCE -eq 1 ]]; then
					    source "$rootDir/bash/scripts/build-basic-app-rmddatasource.sh"
					    build-basic-app-rmddatasource-main $1
					  fi
	          break
						;;
					-script) #ignore
	          break
						;;
	        *)
            echo 'WARN: Unknown option (ignored) in runFunction: %s\n' "$2" >&2
            break
						;;
	    esac
	done
}
