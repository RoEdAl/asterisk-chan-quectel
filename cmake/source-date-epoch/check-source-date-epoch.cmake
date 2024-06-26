#
# SOURCE_DATE_EPOCH
#

IF(NOT DEFINED ENV{SOURCE_DATE_EPOCH})
    MESSAGE(FATAL_ERROR "Environment variable SOURCE_DATE_EPOCH not defined")
ENDIF()

FILE(STRINGS source-date-epoch.env CFG_SOURCE_DATE)
LIST(GET CFG_SOURCE_DATE 0 CFG_SOURCE_DATE_EPOCH )
LIST(GET CFG_SOURCE_DATE 1 CFG_SOURCE_DATE_STR )
MESSAGE(DEBUG "Configuration: SOURCE_DATE_EPOCH=${CFG_SOURCE_DATE_EPOCH} # ${CFG_SOURCE_DATE_STR}")

STRING(TIMESTAMP SOURCE_DATE_STR UTC)
IF("$ENV{SOURCE_DATE_EPOCH}" EQUAL "${CFG_SOURCE_DATE_EPOCH}")
    MESSAGE(STATUS "SOURCE_DATE_EPOCH=$ENV{SOURCE_DATE_EPOCH} # ${SOURCE_DATE_STR}")
ELSE()
    MESSAGE(FATAL_ERROR "Wrong value of SOURCE_DATE_EPOCH: <${SOURCE_DATE_STR} [@$ENV{SOURCE_DATE_EPOCH}]> != <${CFG_SOURCE_DATE_STR} [@${CFG_SOURCE_DATE_EPOCH}]>")
ENDIF()