#
# TODO:
#   - null
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - null
#
# ARGS:
#   - arg : string : "a,b"
#
# RETURN:
#   - null
#
def getDockerImagePaths($arg; $array_type):
  . as $default_obj
  | $arg | split(",")
  | if (. | length) == 0 then
      ["null"]
    end
  | if (. | length) == 1 then
      if .[0] == "null" then
        $default_obj
      end
    else
      [
        .[]
        | select(. != "null")
      ]
    end
  | map(
      select(
        . as $item
        | $default_obj
        | index($item) != null
      )
    )
  | if $array_type == "bash-array" then
      .[]
    else
      .
    end
;

def splitStr($_str):
  $_str
  | if (. | contains(",")) then
      split(",")
    else
      [.]
    end
;