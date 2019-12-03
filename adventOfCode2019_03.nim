
import parsecsv
from streams import newFileStream
import strutils
import math

type
  PointType = tuple
    x: BiggestInt
    y: BiggestInt
    direction: char
    steps: BiggestInt

  WireType = seq[PointType]
  WiresType = seq[WireType]

proc onSegment(p, q, r: PointType): bool =
  return ( (q.x <= max(p.x, r.x)) and (q.x >= min(p.x, r.x)) and (q.y <= max(
      p.y, r.y)) and (q.y >= min(p.y, r.y)))

proc orientation(p, q, r: PointType): BiggestInt =
  let val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
  if (val == 0):
    return 0
  if (val > 0):
    return 1
  return 2

proc doIntersect(p1, q1, p2, q2: PointType): bool =
  let o1 = orientation(p1, q1, p2)
  let o2 = orientation(p1, q1, q2)
  let o3 = orientation(p2, q2, p1)
  let o4 = orientation(p2, q2, q1)

  if ((o1 != o2) and (o3 != o4)):
    return true

  if ((o1 == 0) and onSegment(p1, p2, q1)):
    return true

  if ((o2 == 0) and onSegment(p1, q2, q1)):
    return true

  if ((o3 == 0) and onSegment(p2, p1, q2)):
    return true

  if ((o4 == 0) and onSegment(p2, q1, q2)):
    return true

  return false

proc manhattandDistance(aPointFrom, aPointTo: PointType): BiggestInt =
  var lDeltaX = (aPointTo.x-aPointFrom.x)
  lDeltaX *= sgn(lDeltaX)
  var lDeltaY = (aPointTo.y-aPointFrom.y)
  lDeltaY *= sgn(lDeltaY)
  return (lDeltaX + lDeltaY)

proc intersection(aPointA, aPointB, aPointC: PointType): PointType =
  var lX = aPointA.x;
  if (lX != aPointB.x):
    lX = aPointC.x
  var lY = aPointA.y;
  if (lY != aPointB.y):
    lY = aPointC.y
  result.x = lX
  result.y = lY
  result.steps = manhattandDistance(aPointA, result) + manhattandDistance(
      aPointC, result)

proc loadWires(aInput: string = "input"): WiresType =
  var lFileStream = aInput.newFileStream(fmRead)
  if lFileStream == nil:
    quit("cannot open the file" & aInput)
  var lCsvParser: CsvParser
  lCsvParser.open(lFileStream, aInput)
  result = @[]
  while lCsvParser.readRow:
    var lPoint: PointType
    var lWire = @[lPoint]
    for val in lCsvParser.row.items:
      let lInc: BiggestInt = val.substr(1).parseInt
      lPoint.direction = val[0]
      lPoint.steps = lInc
      case lPoint.direction:
        of 'U':
          lPoint.y += lInc
        of 'D':
          lPoint.y -= lInc
        of 'R':
          lPoint.x += lInc
        of 'L':
          lPoint.x -= lInc
        else:
          discard
      lWire.add(lPoint)
    result.add(lWire)
  close(lCsvParser)

proc partOne =
  var lMinManhattan: BiggestInt = high(BiggestInt)
  let lWires = loadWires()
  var lWire0Index = 1
  var lPoint0A: PointType
  while (lWire0Index < lWires[0].len):
    var lPoint0B = lWires[0][lWire0Index]
    var lWire1Index = 1
    var lPoint1A: PointType
    while (lWire1Index < lWires[1].len):
      var lPoint1B = lWires[1][lWire1Index]
      let lDoIntersect = doIntersect(lPoint0A, lPoint0B,
          lPoint1A, lPoint1B)
      if lDoIntersect:
        # echo "$1 --> $2"%[$lPoint0A, $lPoint0B]
        # echo "$1 --> $2"%[$lPoint1A, $lPoint1B]
        let lIntersection = intersection(lPoint0A, lPoint0B, lPoint1A)
        # echo "intersection $1"%[$lIntersection]
        let lManhattan = (lIntersection.x * lIntersection.x.sgn)+(
            lIntersection.y * lIntersection.y.sgn)
        # echo "md " & $(lManhattan)
        if (lManhattan > 0) and (lMinManhattan > lManhattan):
          lMinManhattan = lManhattan
        #   echo "min md " & $lMinManhattan
      lPoint1A = lPoint1B
      lWire1Index += 1
    lPoint0A = lPoint0B
    lWire0Index += 1
  echo "partOne $1"%[$lMinManhattan]

proc partTwo =
  var lMinSteps: BiggestInt = high(BiggestInt)
  let lWires = loadWires()
  var lWire0Index = 1
  var lWire0Steps: BiggestInt = 0
  var lPoint0A: PointType
  while (lWire0Index < lWires[0].len):
    var lPoint0B = lWires[0][lWire0Index]
    var lWire1Index = 1
    var lWire1Steps: BiggestInt = 0
    var lPoint1A: PointType
    while (lWire1Index < lWires[1].len):
      var lPoint1B = lWires[1][lWire1Index]
      let lDoIntersect = doIntersect(lPoint0A, lPoint0B,
      lPoint1A, lPoint1B)
      if lDoIntersect:
        echo "$1 --> $2"%[$lPoint0A, $lPoint0B]
        echo "$1 --> $2"%[$lPoint1A, $lPoint1B]
        let lIntersection = intersection(lPoint0A, lPoint0B, lPoint1A)
        echo "intersection $1"%[$lIntersection]
        let lSteps = lWire0Steps + lWire1Steps + lIntersection.steps
        echo "lSteps " & $(lSteps)
        if (lSteps > 0) and (lMinSteps > lSteps):
          lMinSteps = lSteps
          echo "min lSteps " & $lMinSteps
      lWire1Steps += lPoint1B.steps
      lPoint1A = lPoint1B
      lWire1Index += 1
    lWire0Steps += lPoint0B.steps
    lPoint0A = lPoint0B
    lWire0Index += 1
  echo "partTwo $1"%[$lMinSteps]

# echo $loadWires()
partOne() #2050
partTwo() #21666
