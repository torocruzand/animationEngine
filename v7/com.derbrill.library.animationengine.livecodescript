script "com.derbrill.library.animationengine"
/*
* animationEngine 7.0.0
* ©2005 - 2022 derbrill IT service. To get in touch contact info@derbrill.de
* This stack was written by Malte Pfaff-Brill with the help of quite a few people
* No rocket sience involved, however many books read any a lot of work went into
* this stack.

* Licensing terms: animationEngine is set free into the Public Domain. The Software is provided "as is" with no warranty.
* Availability of source code: you will find the latest sources and documentation on Github.

* https://github.com/derbrill/animationEngine

* Finally, thank you for helping out! If you purchased a license for animationEngine, I really appreciate that!
* It helped moving the library forward!
*/

on extensionInitialize
   if the target is not me then pass extensionInitialize

   set the itemdel to "."
   set the _ideoverride of me to true

   if first item of the version < 8 then
      if "dev" begins with the environment then
         answer "Sorry, this version of animationEngine requires a Livecode 8.0 or higher engine."
      end if
      remove the script of me from back
      exit extensionInitialize
   end if

   insert the script of me into back
   aeResetFrameRate
end extensionInitialize

on extensionFinalize
   if the target is not me then pass extensionFinalize
   remove the script of me from back
end extensionFinalize

/**
Type: library

Title: AnimationEngine 7

Author: derbrill IT-Service

Version: 7.0.0

SVGIcon: M163.56373,61.06021c16.74112,-3.23761 26.74829,3.04772 30.94722,7.24428c3.1308,3.12843 6.08358,9.5633 5.38574,10.7786c0,0 -4.2915,-2.27867 -15.82253,1.56421c-13.56285,4.52174 -19.47316,24.51709 -40.33963,32.51381c-16.6533,6.38503 -27.64315,-4.34609 -27.64315,-4.34609c0,0 -4.73299,4.81607 -1.73749,10.43205c2.78188,5.21721 6.00525,5.36912 9.68436,11.4978c1.04439,1.73749 1.38619,4.09449 0.5222,6.4325c0,0 -1.07525,3.06197 -2.43296,2.61098c-1.56659,-0.5222 -1.64966,-1.99147 -3.07858,-4.71638c-2.90483,-5.54548 -8.8854,-5.02827 -15.79761,-4.43083c-6.73894,0.58272 -14.36347,1.24188 -20.88665,-3.56589c-3.68148,-2.71304 -6.13105,-6.99505 -9.73895,-9.21438c-4.51937,-2.78425 -8.68981,-3.30645 -14.0803,-4.69739c-4.89369,-1.263 -8.12798,-2.76859 -10.75296,-3.99029c-5.11989,-2.38311 -7.92147,-3.68718 -16.19709,-0.00926c-8.81799,3.92074 -13.2258,-0.65464 -17.21587,-4.79661c-1.19868,-1.24425 -2.35968,-2.44934 -3.59126,-3.37339c-2.86258,-2.14812 -3.65062,-2.4923 -6.08358,-2.54927c-1.39711,-0.03371 -2.31181,0.15001 -2.95594,0.27937c-0.84966,0.1709 -1.22854,0.24686 -1.62277,-0.39568c-0.26585,-0.432 -0.23261,-1.15833 1.3316,-2.02707c3.46786,-1.92975 5.61835,-2.39498 13.50351,1.15595c7.5932,3.42276 7.68815,-4.88728 2.46619,-4.1206c-7.24903,1.06101 -11.15363,0.27771 -12.95283,-2.41872c-0.57916,-0.87112 -0.63613,-5.25994 2.55164,-9.02924c5.28132,-6.24024 9.94237,-6.69431 12.45342,-6.9388c0.82056,-0.07999 1.41135,-0.13743 1.71945,-0.3672c5.31453,-3.96394 7.63593,-0.48422 7.63593,-0.48422c0,0 -2.3214,1.54522 -1.35296,3.3824c0.27249,0.51697 0.97176,0.59981 2.29956,0.75695c3.39095,0.40162 10.88114,1.28887 25.83018,11.1325c8.1059,5.33827 27.21115,12.74395 40.01444,12.85551c10.82607,0.09732 16.08838,-0.04035 20.78102,-2.99551c13.95212,-8.78951 12.38554,-31.44806 47.15666,-38.17014zM12.62777,84.19823c0,0.60527 0.49134,1.09898 1.09898,1.09898c0.60765,0 1.09898,-0.49134 1.09898,-1.09898c0,-0.60765 -0.49134,-1.09898 -1.09898,-1.09898c-0.60765,0 -1.09898,0.49371 -1.09898,1.09898z

OS: mac, windows, linux, ios, android

Platforms: desktop, mobile, web

Summary: Helps you create beautiful animations in LiveCode.

Description:
AnimationEngine is your helper to create beautiful animations in LiveCode. Beyond linear, circular, elliptical or movement on any arbitrary path, it helps you checking for collisions, find distances and angles between objects and is packed with implementations of useful geometrical functions. All handlers and functions are optimized to work as quickly as possible.

Tags:
animations
*/

constant kVersionNumber = "7.0.0"
constant kCreationDate = "©2005 by derbrill IT service"

local sAELockMorph, sAEMorphing
local sAELockMorphGradientRamp, sAEMorphGradientRamp
local sAELockRotateGroup, sAERotateGroup
local sTemp = ""
local sTimeTaken

/**
This function returns the width-to-height ratio of the specified width and height.

Syntax: aspectRatio(pWidth, pHeight)

Example:
get aspectRatio(the width of grc 1, the height of grc 1)

Description:
This function returns the width-to-height ratio of the specified width and height.

Parameters:
pWidth: A positive integer.

pHeight: A positive integer.

Returns:
the aspect ratio.

**/
function aspectRatio pWidth, pHeight
   if pWidth is an integer and pHeight is an integer and pHeight <> 0 then return pWidth / pHeight
   return "Error: Both parameters must be numbers!"
end aspectRatio


# Reserved for internal use
private function _aspectResize pLongId, pLeft, pTop, pRight, pBottom
   local tLeft, tTop, tRight, tBottom, tRectRatio, tRectangle, tAspectResizeArray
   
   _parameterFormat pLongId, pLeft, pTop, pRight, pBottom, sTemp, sTemp, sTemp
   
   switch
      case there is a pLongId and pLeft, pTop, pRight, pBottom is a rectangle
         put the long id of pLongId into pLongId
         put pLeft, pTop, pRight, pBottom into tRectangle
         break
         
      case pLongId, pLeft, pTop, pRight is a rectangle
         put the long id of target into pLongId
         put pLongId, pLeft, pTop, pRight into tRectangle
         break
         
      default
         return "Error: Syntax is aspectResize(the rectangle) or aspectResize(the long id of contol, the rectangle)."
   end switch
   
   # split rectangle into 4 single values
   put item 1 of tRectangle into tLeft
   put item 2 of tRectangle into tTop
   put item 3 of tRectangle into tRight
   put item 4 of tRectangle into tBottom
   
   put _getAnimationEngine(pLongId, "aspectResize") into tAspectResizeArray
   
   # if it isn't already set
   # set the custom property holding the width-to-height ratio
   # to avoid rounding errors later
   if tAspectResizeArray["ratio"] is empty then
      put aspectRatio(the width of pLongId, the height of pLongId) into tAspectResizeArray["ratio"]
      _setAnimationEngine pLongId, "aspectResize", tAspectResizeArray["ratio"]
   end if
   
   # get width-to-height ratio of the target and the rectangle
   put aspectRatio(tRight - tLeft, tBottom - tTop) into tRectRatio
   
   # equal!
   if tAspectResizeArray["ratio"] = tRectRatio then
      return tRight - tLeft, tBottom - tTop
   end if
   
   # not equal,target ratio is bigger/target is heigher
   if tRectRatio < tAspectResizeArray["ratio"] then
      if tAspectResizeArray["ratio"] <> 0 then return "Error description : numeric : divide by zero."
      return (tRight - tLeft),(tRight - tLeft) / tAspectResizeArray["ratio"]
   else
      
      # not equal, target ratio is smaller/target is broader
      return (tBottom - tTop) * tAspectResizeArray["ratio"], tBottom - tTop
   end if
end _aspectResize


--> constrain handlers
function aeInfo
   return animationEngineInfo()
end aeInfo


function animationEngineInfo
   --assemble info text
   return "You are using animationEngine " & kVersionNumber & " built in " & animationEngineDate()
end animationEngineInfo


function aeVersion
   return kVersionNumber
end aeVersion


function animationEngineVersion
   --which version is animationEngine?
   return kVersionNumber
end animationEngineVersion


function animationEngineDate
   --which creation date?
   return kCreationDate
end animationEngineDate

on touchStart pID
   if the environment <> "mobile" then pass touchStart

   local tLongId, tAnimationEngineArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId) into tAnimationEngineArray

   if tAnimationEngineArray is not an array then pass touchStart

   # constrainRectangular
   if tAnimationEngineArray["constrainRectangular"] is not empty then
      _setAnimationEngine tLongId, "ConstrainID", pID
      dispatch "constrainRectangularInit" to tLongId
   end if

   # constrainElliptical
   if tAnimationEngineArray["constrainElliptical"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", true
      _setAnimationEngine tLongId, "ConstrainID", pID
      dispatch "constrainEllipticalInit" to tLongId
   end if

   # constrainCircular
   if tAnimationEngineArray["constrainCircular"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", true
      _setAnimationEngine tLongId, "ConstrainID", pID
      dispatch "constrainCircularInit" to tLongId
   end if

   # constrainLinear
   if tAnimationEngineArray["constrainLinear"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", true
      _setAnimationEngine tLongId, "ConstrainID", pID
      dispatch "constrainLinearInit" to tLongId
   end if

   pass touchStart
end touchStart


on mouseDown
   if the environment = "mobile" then pass mouseDown

   local tLongId, tAnimationEngineArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId) into tAnimationEngineArray

   if tAnimationEngineArray is not an array then pass mouseDown

   # constrainRectangular
   if tAnimationEngineArray["constrainRectangular"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", the mouseH - item 1 of loc of tLongId, the mouseV - item 2 of loc of tLongId
      dispatch "constrainRectangularInit" to tLongId
   end if

   # constrainElliptical
   if tAnimationEngineArray["constrainElliptical"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", true
      dispatch "constrainEllipticalInit" to tLongId
   end if

   # constrainCircular
   if tAnimationEngineArray["constrainCircular"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", true
      dispatch "constrainCircularInit" to tLongId
   end if

   # constrainLinear
   if tAnimationEngineArray["constrainLinear"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", the mouseloc
      dispatch "constrainLinearInit" to tLongId
   end if

   pass mouseDown
end mouseDown


on touchMove pID, pX, pY
   local tLongId, tAnimationEngineArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId) into tAnimationEngineArray

   if tAnimationEngineArray is not an array then pass touchMove

   # constrainRectangular
   if tAnimationEngineArray["constrainRectangular"] is not empty then
      if tAnimationEngineArray["ConstrainID"] = pID and tAnimationEngineArray["AllowConstrainDrag"] is empty then
         _setAnimationEngine tLongId, "AllowConstrainDrag", pX - item 1 of loc of tLongId, pY - item 2 of loc of tLongId
      end if

      dispatch "constrainRectangularInit" to tLongId
   end if

   if tAnimationEngineArray["AllowConstrainDrag"] is not empty then
      dispatch "aeConstrainHandler" to tLongId with pX, pY, pID
   end if
end touchMove


on mouseMove pX, pY
   if the environment = "mobile" then pass mouseMove

   local tLongId
   put the long id of target into tLongId

   if _getAnimationEngine(tLongId, "AllowConstrainDrag") is not empty then
      dispatch "aeConstrainHandler" to tLongId with pX, pY
   end if
   pass mouseMove
end mouseMove


on aeConstrainHandler pX, pY, pID
   local tAllowDragOnLine, tIsAngle, tRadiusX, tRadiusY, tTheAngle, tX1, tX2, tY1, tY2, tTX, tTY
   local tLongId, tAnimationEngineArray, tWidth = 0, tHeight = 0

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId) into tAnimationEngineArray

   if tAnimationEngineArray is not an array then exit aeConstrainHandler
   if tAnimationEngineArray["AllowConstrainDrag"] is empty or pID <> tAnimationEngineArray["ConstrainID"] then exit aeConstrainHandler

   put the width of tLongId into tWidth
   put the height of tLongId into tHeight

   # constrainRectangular
   if tAnimationEngineArray["constrainRectangular"] is a rectangle then
      if tAnimationEngineArray["AllowConstrainDrag"] is not a point then exit aeConstrainHandler

      if tAnimationEngineArray["constrainRectangular"] is a rectangle then
         set the loc of tLongId to min(max(pX - item 1 of tAnimationEngineArray["AllowConstrainDrag"], item 1 of tAnimationEngineArray["constrainRectangular"] + (tWidth / 2)), item 3 of tAnimationEngineArray["constrainRectangular"] - (tWidth / 2)), min(max(pY - item 2 of tAnimationEngineArray["AllowConstrainDrag"], item 2 of tAnimationEngineArray["constrainRectangular"] + (tHeight / 2)), item 4 of tAnimationEngineArray["constrainRectangular"] - (tHeight / 2))
         dispatch "constrainRectangularCallBack" to tLongId
      end if
   end if

   # constrainElliptical
   if tAnimationEngineArray["constrainElliptical"] is a rectangle and tRadiusY <> 0 then

      put item 1 of tAnimationEngineArray["constrainElliptical"] into tTX
      put item 2 of tAnimationEngineArray["constrainElliptical"] into tTY
      put item 3 of tAnimationEngineArray["constrainElliptical"] into tRadiusX
      put item 4 of tAnimationEngineArray["constrainElliptical"] into tRadiusY

      put findAngleX(tTX, tTY, pX, pY) into tIsAngle
      put atan(tRadiusX / tRadiusY * tan(tIsAngle * pi / 180)) * 180 / pi into tTheAngle

      if tIsAngle > 90 and tIsAngle <= 270 then
         add 180 to tTheAngle
      end if

      set the loc of tLongId to pointOnEllipse(tTX, tTY, tTheAngle, tRadiusX, tRadiusY)
      dispatch "constrainEllipticalCallBack" to tLongId
   end if

   # constrainCircular
   if tAnimationEngineArray["constrainCircular"] is a rectangle then
      put item 1 of tAnimationEngineArray["constrainCircular"] into tTX
      put item 2 of tAnimationEngineArray["constrainCircular"] into tTY
      put item 3 of tAnimationEngineArray["constrainCircular"] into tRadiusX
      set the loc of tLongId to pointOnCircle(tTX, tTY, findangleX(tTX, tTY, pX, pY), tRadiusX)
      dispatch "constrainCircularCallBack" to tLongId
   end if

   # constrainLinear
   if tAnimationEngineArray["constrainLinear"] is a rectangle then
      if item 1 of tAnimationEngineArray["constrainLinear"] < item 3 of tAnimationEngineArray["constrainLinear"] then
         put item 1 of tAnimationEngineArray["constrainLinear"] into tX1
         put item 2 of tAnimationEngineArray["constrainLinear"] into tY1
         put item 3 of tAnimationEngineArray["constrainLinear"] into tX2
         put item 4 of tAnimationEngineArray["constrainLinear"] into tY2
       else
         put item 3 of tAnimationEngineArray["constrainLinear"] into tX1
         put item 4 of tAnimationEngineArray["constrainLinear"] into tY1
         put item 1 of tAnimationEngineArray["constrainLinear"] into tX2
         put item 2 of tAnimationEngineArray["constrainLinear"] into tY2
      end if

      put closestPointOnLine(tX1, tY1, tX2, tY2, pX, pY) into tAllowDragOnLine
      put round(item 1 of tAllowDragOnLine) into item 1 of tAllowDragOnLine
      put round(item 2 of tAllowDragOnLine) into item 2 of tAllowDragOnLine

      if circleLineSegmentCollide(tX1, tY1, tX2, tY2, tAllowDragOnLine, 1) = false then

         if distance(pX, pY, tX1, tY1) < distance(pX, pY, tX2, tY2) then
            set the loc of tLongId to tX1, tY1
          else
            set the loc of tLongId to tX2, tY2
         end if

       else
         set the loc of tLongId to tAllowDragOnLine
      end if

      dispatch "constrainLinearCallBack" to tLongId
   end if
end aeConstrainHandler


on mouseUp
   local tLongId, tAnimationEngineArray, tUpdate = true

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId) into tAnimationEngineArray

   if tAnimationEngineArray is not an array then pass mouseUp

   # constrainRectangular
   if tAnimationEngineArray["constrainRectangular"] is not empty then
      _setAnimationEngine tLongId, "AllowConstrainDrag", empty
      dispatch "constrainRectangularExit" to tLongId
      put false into tUpdate
   end if

   # constrainLinear
   if tAnimationEngineArray["constrainLinear"] is not empty then
      if tUpdate then
         _setAnimationEngine tLongId, "AllowConstrainDrag", empty
         put false into tUpdate
      end if

      dispatch "constrainLinearExit" to tLongId
   end if

   # constrainCircular
   if tAnimationEngineArray["constrainCircular"] is not empty then
      if tUpdate then
         _setAnimationEngine tLongId, "AllowConstrainDrag", empty
         put false into tUpdate
      end if
      dispatch "constrainCircularExit" to tLongId
   end if

   # constrainElliptical
   if tAnimationEngineArray["constrainElliptical"] is not empty then
      if tUpdate then
         _setAnimationEngine tLongId, "AllowConstrainDrag", empty
         put false into tUpdate
      end if
      dispatch "constrainEllipticalExit" to tLongId
   end if

   pass mouseUp
end mouseUp


on mouseRelease
   dispatch "aeDragRelease"
   pass mouseRelease
end mouseRelease


on touchRelease
   if _getAnimationEngine(the long id of target, "AllowConstrainDrag") is not empty then dispatch "aeDragRelease"
end touchRelease


on aeDragRelease
   local tLongId, tAnimationEngineArray, tUpdate = true

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId) into tAnimationEngineArray

   if tAnimationEngineArray is not an array then exit aeDragRelease

   # constrainRectangular
   if tAnimationEngineArray["constrainRectangular"] is a rectangle then
      _setAnimationEngine tLongId, "AllowConstrainDrag", empty
      _setAnimationEngine tLongId, "ConstrainID", empty
      put false into tUpdate

      dispatch "constrainRectangularExit" to tLongId
   end if

   # constrainLinear
   if tAnimationEngineArray["constrainLinear"] is not empty then
      if tUpdate then
         _setAnimationEngine tLongId, "AllowConstrainDrag", empty
         _setAnimationEngine tLongId, "ConstrainID", empty
         put false into tUpdate
      end if

      dispatch "constrainLinearExit" to tLongId
   end if

   # constrainCircular
   if tAnimationEngineArray["constrainCircular"] is not empty then
      if tUpdate then
         _setAnimationEngine tLongId, "AllowConstrainDrag", empty
         _setAnimationEngine tLongId, "ConstrainID", empty
         put false into tUpdate
      end if

      dispatch "constrainCircularExit" to tLongId
   end if

   # constrainElliptical
   if tAnimationEngineArray["constrainElliptical"] is not empty then
      if tUpdate then
         _setAnimationEngine tLongId, "AllowConstrainDrag", empty
         _setAnimationEngine tLongId, "ConstrainID", empty
         put false into tUpdate
      end if

      dispatch "constrainEllipticalExit" to tLongId
   end if
end aeDragRelease


on touchEnd
   if _getAnimationEngine(the long id of target, "AllowConstrainDrag") is not empty then dispatch "aeDragRelease"
end touchEnd

--> collision detection
/**
This function returns true if there is a circular collision of the 2 objects. Else it returns false.

Syntax: circleCollide(pX1, pY1, pX2, pY2, pThreshold)
Syntax: circleCollide(pPoint1, pPoint2, pThreshold)

Example:
get circleCollide(100,150,200,140,80)

Example:
get circleCollide(the loc of grc "test",the loc of img "myImage",80)

Description:
This function returns true if there is a circular collision of the 2 objects. Else it returns false. Threshold is the sum of both circles
radii.

Parameters:
pPoint1: First point

pPoint2: Second point

pThreshold: The sum of both circles radii.

Returns:
boolean
**/
function circleCollide pX1, pY1, pX2, pY2, pThreshold
   _parameterFormat pX1, pY1, pX2, pY2, pThreshold, sTemp, sTemp, sTemp

   --check syntax
   if pX1, pY1, pX2, pY2 is not a rectangle or pThreshold is not a number
   then return "Error: Syntax is circleCollide(x1,y1,x2,y2,threshold) or circleCollide(point1, point2, threshold)."

   return distance(pX1, pY1, pX2, pY2) < pThreshold
end circleCollide


/**
get circle line segment collision

Syntax: circleLineSegmentCollide(pX1, pY1, pX2, pY2, pX3, pY3, pRadius)
Syntax: circleLineSegmentCollide(pPoint1, pPoint2, pPoint3, pRadius)

Example:
get circleLineSegmentCollide(100,200,200,250,80,80,40)

Example:
get circleLineSegmentCollide(line 1 of the points of grc "line",line 2 of the points of grc "line",the loc of img "circle",40)

Description:
This function returns true if there is a collision between a line segment (specified by startPoint x1,y1 and the endPoint x2,y2 and
a circle (specified by the circles centerPoint x3,y3 and it's radius). Else it returns false.

Parameters:
pPoint1: First point

pPoint2: Second point

pPoint3: Third point

pRadius: The radio

Returns:
boolean
**/
function circleLineSegmentCollide pX1, pY1, pX2, pY2, pX3, pY3, pRadius
   local tIntersectionPointX, tIntersectionPointY, tTemp, tU

   _parameterFormat pX1, pY1, pX2, pY2, pX3, pY3, pRadius, sTemp

   --check syntax
   if pX1, pY1, pX2, pY2 is not a rectangle or pX3, pY3 is not a point or pRadius is not a number then
      return "Error: Syntax is circleLineSegmentCollide(x1,y1,x2,y2,x3,y3,radius) or circleLineSegmentCollide(point1, point2, point3, radius)."
   end if

   put (pX2 - pX1) ^ 2 + (pY2 - pY1) ^ 2 into tTemp
   if tTemp = 0 then return "Error description : numeric : divide by zero."

   put ((pX3 - pX1) * (pX2 - pX1) + (pY3 - pY1) * (pY2 - pY1)) / tTemp into tU
   put pX1 + tU * (pX2 - pX1) into tIntersectionPointX
   put pY1 + tU * (pY2 - pY1) into tIntersectionPointY

   if tU < 1 and tU > 0 then
      return distance(tIntersectionPointX, tIntersectionPointY, pX3, pX3) < pRadius
   end if

   return distance(pX1, pY1, pX3, pY3) > pRadius and distance(pX2, pY2, pX3, pY3) > pRadius
end circleLineSegmentCollide

--> closest points
/**
This function returns the closest point to x3, y3 that lays on the line specified by the points x1, y1 and x2, y2.

Syntax: closestPointOnLine(pX1, pY1, pX2, pY2, pX3, pY3)
Syntax: closestPointOnLine(pPoint1, pPoint2, pPoint3)

Example:
get closestPointOnLine(10, 10, 200, 40, 20, 20)

Example:
get closestPointOnLine(line 1 of the points of grc "line", line 2 of the points of grc "line", the loc of button "myButton")

Description:
This function returns the closest point to x3, y3 that lays on the line specified by the points x1, y1 and x2, y2. As a line is endless,
this point doesn't necessarily lie on the linesegment specified by x1, y1 / x2, y2, but might lie on the extension of that line.

Parameters:
pPoint1: First point

pPoint2: Second point

pPoint3: Third point

Returns:
point

**/
function closestPointOnLine pX1, pY1, pX2, pY2, pX3, pY3
   local tClosestPointX, tClosestPointY, tTemp, tU

   _parameterFormat pX1, pY1, pX2, pY2, pX3, pY3, sTemp, sTemp

   if (pX1, pY1, pX2, pY2) is not a rectangle or (pX3, pY3) is not a point then
      return "Error: Syntax is closestPointOnLine(x1, y1, x2, y2, x3, y3) or closestPointOnLine(point1, point2, point3)."
   end if

   put ((pX2 - pX1) ^ 2 + (pY2 - pY1) ^ 2) into tTemp

   if tTemp <> 0 then
      put ((pX3 - pX1) * (pX2 - pX1) + (pY3 - pY1) * (pY2 - pY1)) / tTemp into tU
      put pX1 + tU * (pX2 - pX1) into tClosestPointX
      put pY1 + tU * (pY2 - pY1) into tClosestPointY

      return tClosestPointX, tClosestPointY
   end if

   return pX1, pY1
end closestPointOnLine


-- basic geometry
/**
This function returns the slope of a line defined by its start end endpoints. 

Syntax: getSlope(pX1, pY1, pX2, pY2)
Syntax: getSlope(pPoint1, pPoint2)

Example:
get getSlope(10,30,40,50)

Example:
get getSlope(line 1 of the points of grc 1,line 2 of the points of grc 1)

Description:
This function returns the slope of a line defined by its start end endpoints. 

Parameters:
pPoint1: First point

pPoint2: Second point

Returns:
number
**/
function getSlope pX1, pY1, pX2, pY2
   local tTemp

   _parameterFormat pX1, pY1, pX2, pY2, sTemp, sTemp, sTemp, sTemp

   if pX1, pY1, pX2, pY2 is not a rectangle then return "Error: Syntax is getSlope(x1, y1, x2, y2) or getSlope(point1, point2)."
   put pX2 - pX1 into tTemp
   if tTemp <> 0 then return (pY2 - pY1) / tTemp
   return "y"
end getSlope


/**
This function returns the distance between to given points in pixel.

Syntax: distance(pX1, pY1, pX2, pY2)
Syntax: distance(pPoint1, pPoint2)

Example:
get distance(100,100,200,200)

Example:
get distance(the loc of grc "myGraphic",the loc of img "myImage")

Description:
This function returns the distance between to given points in pixel.

Parameters:
pPoint1: First point

pPoint2: Second point

Returns:
number

**/
function distance pX1, pY1, pX2, pY2
   _parameterFormat pX1, pY1, pX2, pY2, sTemp, sTemp, sTemp, sTemp
   if pX1, pY1, pX2, pY2 is not a rectangle then return "Error: Syntax is distance(x1, y1, x2, y2) or distance(point1, point2)."
   return floor(sqrt((pX1 - pX2) ^ 2 + (pY1 - pY2) ^ 2))
end distance


/**
This function returns the center angle of a circle in degrees.

Syntax: findAngle(pX1, pY1, pX2, pY2)
Syntax: findAngle(pPoint1, pPoint2)

Example:
get findAngle(100,200,50,300)

Example:
get findAngle(the loc of grc "myGraphic,the loc of btn "myButton")

Description:
This function returns the center angle of a circle in degrees. x1,y1 are the coordinates of the center point of the circle. x2,y2 are 
the coordinates of a point on the circular arc. Possible values are 0-360, where 0 degrees means x2,y2 being on top of x1,y1.

Parameters:
pPoint1: First point

pPoint2: Second point

Returns:
number

**/
function findAngle pX1, pY1, pX2, pY2
   local tAngle

   _parameterFormat pX1, pY1, pX2, pY2, sTemp, sTemp, sTemp, sTemp
   if pX1, pY1, pX2, pY2 is not a rectangle then return "Error: Syntax is findAngle(x1, y1, x2, y2) or findAngle(point1, point2)."

   put findPreciseAngle(pX1, pY1, pX2, pY2) into tAngle
   if tAngle is a number then return floor(tAngle)
end findAngle


/**
This function returns the center angle of a circle in degrees.

Syntax: findPreciseAngle(pX1, pY1, pX2, pY2)
Syntax: findPreciseAngle(pPoint1, pPoint2)

Example:
get findPreciseAngle(100,200,50,300)

Example:
get findPreciseAngle(the loc of grc "myGraphic,the loc of btn "myButton")

Description:
This function returns the center angle of a circle in degrees. x1,y1 are the coordinates of the center point of the circle. x2,y2 are 
the coordinates of a point on the circular arc. Possible values are 0-360, where 0 degrees means x2,y2 being on top of x1,y1. In 
difference to the findAngle function values are not rounded.

Parameters:
pPoint1: First point

pPoint2: Second point

Returns:
number

**/
function findPreciseAngle pX1, pY1, pX2, pY2
   local tAdjacentLeg, tAlpha

   _parameterFormat pX1, pY1, pX2, pY2, sTemp, sTemp, sTemp, sTemp

   if pX1, pY1, pX2, pY2 is not a rectangle then return "Error: Syntax is findPreciseAngle(x1, y1, x2, y2) or findPreciseAngle(point1, point2)."
   put abs(pY1 - pY2) into tAdjacentLeg

   if tAdjacentLeg <> 0 then
      put atan(abs(pX1 - pX2) / tAdjacentLeg) into tAlpha
      put tAlpha * 180 / pi into tAlpha
   else put 90 into tAlpha

   switch
      case pX1 <= pX2 and pY1 >= pY2
         return tAlpha
         break

      case pX1 <= pX2 and pY1 <= pY2
         return (180 - tAlpha)
         break

      case pX1 >= pX2 and pY1 <= pY2
         return (180 + tAlpha)
         break

      case pX1 >= pX2 and pY1 >= pY2
         return (360 - tAlpha)
         break
   end switch

end findPreciseAngle


/**
This function returns the center angle of a circle in degrees.

Syntax: findPreciseAngleX(pX1, pY1, pX2, pY2)
Syntax: findPreciseAngleX(pPoint1, pPoint2)

Example:
get findPreciseAngleX(100,200,50,300)

Example:
get findPreciseAngleX(the loc of grc "myGraphic,the loc of btn "myButton")

Description:
This function returns the center angle of a circle in degrees. x1,y1 are the coordinates of the center point of the circle. x2,y2 are the coordinates 
of a point on the circular arc. Possible values are 0-360, where 0 degrees means x2,y2 being right to x1,y1. In difference to 
findAngleX() the returned value is not rounded.


Parameters:
pPoint1: First point

pPoint2: Second point

Returns:
number

**/
function findPreciseAngleX pX1, pY1, pX2, pY2
   local tFoundAngle

   _parameterFormat pX1, pY1, pX2, pY2, sTemp, sTemp, sTemp, sTemp

   if pX1, pY1, pX2, pY2 is not a rectangle then return "Error: Syntax is findPreciseAngleX(x1, y1, x2, y2) or findPreciseAngleX(point1, point2)."
   put findPreciseAngle(pX1, pY1, pX2, pY2) - 90 into tFoundAngle
   if tFoundAngle < 0 then put 360 + tFoundAngle into tFoundAngle

   return tFoundAngle
end findPreciseAngleX


/**
This function returns the center angle of a circle in degrees.

Syntax: findAngleX(pX1, pY1, pX2, pY2)
Syntax: findAngleX(pPoint1, pPoint2)

Example:
get findAngleX(100,200,50,300)

Example:
get findAngleX(the loc of grc "myGraphic,the loc of btn "myButton")

Description:
This function returns the center angle of a circle in degrees. x1,y1 are the coordinates of the center point of the circle. x2,y2 are the coordinates 
of a point on the circular arc. Possible values are 0-360, where 0 degrees means x2,y2 being right to x1,y1.


Parameters:
pPoint1: First point

pPoint2: Second point

Returns:
number

**/
function findAngleX pX1, pY1, pX2, pY2
   local tFoundAngle

   _parameterFormat pX1, pY1, pX2, pY2, sTemp, sTemp, sTemp, sTemp

   if pX1, pY1, pX2, pY2 is not a rectangle then return "Error: Syntax is findAngleX(x1, y1, x2, y2) or findAngleX(point1, point2)."
   put findAngle(pX1, pY1, pX2, pY2) - 90 into tFoundAngle
   if tFoundAngle < 0 then put 360 + tFoundAngle into tFoundAngle

   return tFoundAngle
end findAngleX

/**
This function returns the center angle of a circle in degrees.

Syntax: findAngleY(pX1, pY1, pX2, pY2)
Syntax: findAngleY(pPoint1, pPoint2)

Example:
get findAngleY(100,200,50,300)

Example:
get findAngleY(the loc of grc "myGraphic,the loc of btn "myButton")

Description:
This function returns the center angle of a circle in degrees. x1,y1 are the coordinates of the center point of the circle. x2,y2 are the coordinates 
of a point on the circular arc. Possible values are 0-360, where 0 degrees means x2,y2 being on top of x1,y1.


Parameters:
pPoint1: First point

pPoint2: Second point

Returns:
number

**/
function findAngleY pX1, pY1, pX2, pY2
   _parameterFormat pX1, pY1, pX2, pY2, sTemp, sTemp, sTemp, sTemp

   if pX1, pY1, pX2, pY2 is not a rectangle then return "Error: Syntax is findAngleY(x1, y1, x2, y2) or findAngleY(point1, point2)."
   return findAngle(pX1, pY1, pX2, pY2)
end findAngleY


function findAngle2 pX1, pY1, pX2, pY2, pStartAngle
   local tFoundAngle

   _parameterFormat pX1, pY1, pX2, pY2, pStartAngle, sTemp, sTemp, sTemp

   if pX1, pY1, pX2, pY2 is not a rectangle or pStartAngle is not a number then return "Error: Syntax is findAngleY(x1, y1, x2, y2, pStartAngle) or findAngleY(point1, point2, pStartAngle)."
   put findAngle(pX1, pY1, pX2, pY2) - 90 - pStartAngle into tFoundAngle
   if tFoundAngle < 0 then return 360 + tFoundAngle
   if tFoundAngle > 360 then return tFoundAngle mod 360

   return tFoundAngle
end findAngle2


# new in this version 7
function rectanglesIntersect pLeft1, pTop1, pRight1, pBottom1, pLeft2, pTop2, pRight2, pBottom2
   -- https://stackoverflow.com/questions/2752349/fast-rectangle-to-rectangle-intersection

   _parameterFormat pLeft1, pTop1, pRight1, pBottom1, pLeft2, pTop2, pRight2, pBottom2

   if (pLeft1, pTop1, pRight1, pBottom1) is not a rectangle or (pLeft2, pTop2, pRight2, pBottom2) is not a rectangle
   then return "Error: Syntax is rectanglesIntersect(left1, top1, right1, bottom1, left2, top2, right2, bottom2) or rectanglesIntersect(rectangle1, rectangle2)."
   return not(pLeft2 > pRight1 or pRight2 < pLeft1 or pTop2 > pBottom1 or pBottom2 < pTop1)
end rectanglesIntersect


// Function to find intersection rectangle of given two rectangles.
function intersectRect pLeft1, pTop1, pRight1, pBottom1, pLeft2, pTop2, pRight2, pBottom2
   local tLeft, tTop, tRight, tBottom

   -- https://www.geeksforgeeks.org/intersecting-rectangle-when-bottom-left-and-top-right-corners-of-two-rectangles-are-given/

   _parameterFormat pLeft1, pTop1, pRight1, pBottom1, pLeft2, pTop2, pRight2, pBottom2

   if (pLeft1, pTop1, pRight1, pBottom1) is not a rectangle or (pLeft2, pTop2, pRight2, pBottom2) is not a rectangle
   then return "Error: Syntax is intersectRect(left1, top1, right1, bottom1, left2, top2, right2, bottom2) or intersectRect(rectangle1, rectangle2)."

   if pLeft1 > pLeft2 then put pLeft1 into tLeft
   else put pLeft2 into tLeft

   if pTop1 > pTop2 then put pTop1 into tTop
   else put pTop2 into tTop

   if pRight1 > pRight2 then put pRight1 into tRight
   else put pRight2 into tRight

   if pBottom1 > pBottom2 then put pBottom1 into tBottom
   else put pBottom2 into tBottom

   // No intersection
   if tLeft > tRight or tTop > tBottom then return "No intersection"
   return tLeft, tTop, tRight, tBottom
end intersectRect


function maskComparePoints pLeft1, pTop1, pRight1, pBottom1, pLeft2, pTop2, pRight2, pBottom2
   local tInterceptRectangle, s1, e1, t1, b1, s2, e2, t2, b2

   _parameterFormat pLeft1, pTop1, pRight1, pBottom1, pLeft2, pTop2, pRight2, pBottom2

   if (pLeft1, pTop1, pRight1, pBottom1) is not a rectangle or (pLeft2, pTop2, pRight2, pBottom2) is not a rectangle
   then return "Error: Syntax is maskComparePoints(left1, top1, right1, bottom1, left2, top2, right2, bottom2) or maskComparePoints(rectangle1, rectangle2)."

   put intersectRect(pLeft1, pTop1, pRight1, pBottom1, pLeft2, pTop2, pRight2, pBottom2) into tInterceptRectangle
   if tInterceptRectangle is "No intersection" then return empty

   put abs(pLeft1 - item 1 of tInterceptRectangle) + 1 into s1
   put abs(pLeft1 - item 3 of tInterceptRectangle) + 1 into e1
   put abs(pTop1 - item 2 of tInterceptRectangle) + 1 into t1
   put abs(pTop1 - item 4 of tInterceptRectangle) + 1 into b1
   put abs(pLeft2 - item 1 of tInterceptRectangle) + 1 into s2
   put abs(pLeft2 - item 3 of tInterceptRectangle) + 1 into e2
   put abs(pTop2 - item 2 of tInterceptRectangle) + 1 into t2
   put abs(pTop2 - item 4 of tInterceptRectangle) + 1 into b2

   return s1, e1, t1, b1, s2, e2, t2, b2
end maskComparePoints


function midLeft pLongId
   if there is not a pLongId then return empty
   return the left of pLongId, item 2 of the loc of pLongId
end midleft


function midRight pLongId
   if there is not a pLongId then return empty
   return the right of pLongId, item 2 of the loc of pLongId
end midRight


function midTop pLongId
   if there is not a pLongId then return empty
   return item 1 of the loc of pLongId, the top of pLongId
end midTop


function midBottom pLongId
   if there is not a pLongId then return empty
   return item 1 of the loc of pLongId, the bottom of pLongId
end midBottom


function splitAlpha pLongId
   local i = 0, tAlpha, tData, tLength, tLoops

   if there is a pLongId then return "Error: The object you reference does not exist."
   if first word of pLongId is not "image" then return "Error: The object you are referencing is not an image."

   put the alphaData of pLongId into tAlpha
   put the width of pLongId
   replace numtochar(10) with numtochar(17) in tAlpha
   replace numtochar(13) with numtochar(17) in tAlpha

   put the width of pLongId into tLength
   put the number of chars of tAlpha div tLength into tLoops
   put tAlpha into tData

   repeat with i = tLoops down to 1
      put char tLength * i of tData & cr into char tLength * i of tData
      wait 0 with messages
   end repeat

   return tData
end splitAlpha


function imageCollide pLongIdObject1, pLongIdObject2, pThreshold
   local tData1, tData2, tMaskComparePoints, tOffset1, tOffset2, tOffset3, tOffset4
   local tEndCounterLine, tEndCounterChar, tCounterLine, tCounterChar, tFirst, tSecond

   if there is a pLongIdObject1 then return "Error: The object referenced in the first parameter does not exist."
   if there is a pLongIdObject2 then return "Error: The object referenced in the second parameter does not exist."
   if first word of pLongIdObject1 is not "image" then return "Error: The object you reference in the first parameter is not an image."
   if first word of pLongIdObject2 is not "image" then return "Error: The object you reference in the second parameter is not an image."
   if pThreshold is empty then put 0 into pThreshold
   if not intersect (pLongIdObject1, pLongIdObject1, "bounds") then return false

   put splitAlpha(pLongIdObject1) into tData1
   put splitAlpha(pLongIdObject2) into tData2
   put maskComparePoints(the rect of pLongIdObject1, the rect of pLongIdObject2) into tMaskComparePoints
   if tMaskComparePoints then return false

   put item 3 of tMaskComparePoints into tOffset1
   put item 1 of tMaskComparePoints into tOffset2
   put item 7 of tMaskComparePoints into tOffset3
   put item 5 of tMaskComparePoints into tOffset4
   put item 4 of tMaskComparePoints - item 3 of tMaskComparePoints into tEndCounterLine
   put item 2 of tMaskComparePoints - item 1 of tMaskComparePoints into tEndCounterChar
   put - 1 into tCounterLine

   repeat for each line tLine in tData1
      add 1 to tCounterLine
      put - 1 into tCounterChar

      repeat for each char tChar in line (tOffset1 + tCounterLine) of tData1
         add 1 to tCounterChar
         if tCounterChar > tEndcounterchar then
            exit repeat
         end if

         put chartonum(char(tCounterChar + tOffset2) of line (tCounterLine + tOffset1) of tData1) into tFirst
         put chartonum(char(tCounterChar + tOffset4) of line (tCounterLine + tOffset3) of tData2) into tSecond
         if tFirst + tSecond > 255 + pThreshold then return true
      end repeat

      if tCounterLine > tEndCounterLine then
         return false
      end if
   end repeat

   return false
end imageCollide


function pointOnCircle pCenterX, pCenterY, pAngle, pRadius
   local tNewX, tNewY
   
   _parameterFormat pCenterX, pCenterY, pAngle, pRadius, sTemp, sTemp, sTemp, sTemp
   
   if pCenterX, pCenterY, pAngle, pRadius is not a rectangle
   then return "Error: Syntax is pointOnCircle(CenterX, CenterY, Angle, Radius)."
   
   put pCenterX + cos(pAngle * pi / 180) * pRadius into tNewX
   put pCenterY + sin(pAngle * pi / 180) * pRadius into tNewY
   return floor(tNewX), floor(tNewY)
end pointOnCircle


function pointOnEllipse pCenterX, pCenterY, pAngle, pRadiusx, pRadiusY
   local tEllipseNewX, tEllipseNewY

   _parameterFormat pCenterX, pCenterY, pAngle, pRadiusX, pRadiusY, sTemp, sTemp, sTemp

   if (pCenterX, pCenterY, pAngle, pRadiusX) is not a rectangle or pRadiusY is not a number
   then return "Error: Syntax is pointOnEllipse(CenterX, CenterY, Angle, RadiusX, RadiusY)."

   put pCenterX + cos(pAngle * pi / 180) * pRadiusX into tEllipseNewX
   put pCenterY + sin(pAngle * pi / 180) * pRadiusY into tEllipseNewY

   return tEllipseNewX, tEllipseNewY
end pointOnEllipse


function pointOnLine pX1, pY1, pX2, pY2, pDistance
   local tMyAngle, tNewX, tNewY

   _parameterFormat pX1, pY1, pX2, pY2, pDistance, sTemp, sTemp, sTemp

   if (pX1, pY1, pX2, pY2) is not a rectangle or pDistance is not a number
   then return "Error: Syntax is pointOnLine(x1, y1, x2, y2, distance) or pointOnLine(point1, point2, distance)."

   put findAngle(pX1, pY1, pX2, pY2) - 90 into tMyAngle
   put round(pX1 + cos(tMyAngle * pi / 180) * pDistance) into tNewX
   put round(pY1 + sin(tMyAngle * pi / 180) * pdistance) into tNewY

   return tNewX, tNewY
end pointOnLine

--Added in AE 1.5
function whereIsThePoint pX1, pY1, pX2, pY2, pX3, pY3
   local tWhere

   _parameterFormat pX1, pY1, pX2, pY2, pX3, pY3, sTemp, sTemp

   if (pX1, pY1, pX2, pY2) is not a rectangle or (pX3, pY3) is not a point
   then return "Error: Syntax is whereIsThePoint(x1, y1, x2, y2, x3, y3) or whereIsThePoint(point1, point2, point3)."
   put (pX2 - pX1) * (pY3 - pY1) - (pX3 - pX1) * (pY2 - pY1) into tWhere

   switch
      case tWhere < 0
         return "right"
         break
      case tWhere > 0
         return "left"
         break
      default
         return "on"
         break
   end switch
end whereIsThePoint


function pointInPoly pX, pY, pPointlist
   local tParameters, tMyCounter = 0, tLength = 0, tTot, tContainsP = false

   put pX, pY, pPointlist into tParameters
   put item 1 of tParameters into pX
   put item 2 of tParameters into pY
   put item 3 to - 1 of tParameters into pPointlist

   if (pX, pY) is not a point or pPointlist is empty then return "Error in parameters." & cr & "Syntax: pointInPoly(x,y,pointlist) or pointInPoly(point,pointlist)."
   if the number of lines of pPointlist < 3 then return "error. Pointlist must contain at least 3 lines"

   put the number of lines of pPointlist into tLength
   put tLength into tTot

   repeat with i = 1 to tTot
      if (item 1 of line i of pPointlist is not a number or item 2 of line i of pPointlist is not a number) or \
            (item 1 of line tLength of pPointlist is not a number or item 2 of line tLength of pPointlist is not a number) then
         return "Error in pointlist."
      end if

      if ((item 2 of line i of pPointlist <= pY and pY < item 2 of line tLength of pPointlist)) or ((item 2 of line tLength of pPointlist <= pY) and (pY < item 2 of line i of pPointlist)) then
         if pX <((item 1 of line tLength of pPointlist - item 1 of line i of pPointlist) * (pY - item 2 of line i of pPointlist) / (item 2 of line tLength of pPointlist - item 2 of line i of pPointlist)) + item 1 of line i of pPointlist then
            put not tContainsP into tContainsP
         end if
      end if

      put i into tLength
   end repeat

   return tContainsP
end pointInPoly

-- https://stackoverflow.com/questions/54865655/we-have-2-lines-how-can-we-get-point-where-that-2-lines-intersect-with-javascri
function lineSegmentIntersectionPoint pX1, pY1, pX2, pY2, pX3, pY3, pX4, pY4
   local tXS = "", tXRange1, tXRange2, tYRange1, tYRange2
   local tZ1, tZ2, tZ3, tZ4, tDistance, tTempA, tTempB, tXCoor, tYCoor

   _parameterFormat pX1, pY1, pX2, pY2, pX3, pY3, pX4, pY4

   if (pX1, pY1, pX2, pY2) is not a rectangle or (pX3, pY3, pX4, pY4) is not a rectangle
   then return "Error: Syntax is lineSegmentIntersectionPoint(x1, y1, x2, y2, x3, y3, x4, y4) or lineSegmentIntersectionPoint(point1, point2, point3, point4)."

   put pX1 - pX2 into tZ1
   put pX3 - pX4 into tZ2
   put pY1 - pY2 into tZ3
   put pY3 - pY4 into tZ4
   put tZ1 * tZ4 - tZ3 * tZ2 into tDistance

   # no intersectionPoint
   if tDistance is 0 then return "no intersectionPoint"

   put pX1 * pY2 - pY1 * pX2 into tTempA
   put pX3 * pY4 - pY3 * pX4 into tTempB
   put (tTempA * tZ2 - tZ1 * tTempB) / tDistance into tXCoor
   put (tTempA * tZ4 - tZ3 * tTempB) / tDistance into tYCoor

   if (tXCoor < min(pX1, pX2) or tXCoor > max(pX1, pX2) or tXCoor < min(pX3, pX4) or tXCoor > max(pX3, pX4)) then
      # no intersectionPoint
      return "no intersectionPoint"
   end if

   if (tYCoor < min(pY1, pY2) or tYCoor > max(pY1, pY2) or tYCoor < min(pY3, pY4) or tYCoor > max(pY3, pY4)) then -- in Y
      # no intersectionPoint
      return "no intersectionPoint"
   end if

   return trunc(tXCoor), trunc(tYCoor)
end lineSegmentIntersectionPoint


function lineIntersectionPoint pX1, pY1, pX2, pY2, pX3, pY3, pX4, pY4
   local i, m1, m2, t1, t2, xs = "", ys

   _parameterFormat pX1, pY1, pX2, pY2, pX3, pY3, pX4, pY4

   if (pX1, pY1, pX2, pY2) is not a rectangle or (pX3, pY3, pX4, pY4) is not a rectangle
   then return "Error: Syntax is lineIntersectionPoint(x1, y1, x2, y2, x3, y3, x4, y4) or lineIntersectionPoint(point1, point2, point3, point4)."

   --Workaround funktioniert nicht...
   --Die zurückgegebene Steigung ist einfach zu groß.
   --Kannst Du mal versuchen deine Parallel zur y Achse version einzubauen?
   switch
      case pX2 is not pX1 and pX4 is not pX3
         put (pY2 - pY1) / (pX2 - pX1) into m1
         put (pY4 - pY3) / (pX4 - pX3) into m2

         if m1 = m2 then return "parallel"

         put - (m1 * pX1 - pY1) into t1
         put - (m2 * pX3 - pY3) into t2
         put (t2 - t1) / (m1 - m2) into xs
         put m1 * xs + t1 into ys
         break

      case pX2 is pX1 and pX4 is not pX3
         put (pY4 - pY3) / (pX4 - pX3) into m2
         put - (m2 * pX3 - pY3) into t2
         put pX2 into xs
         put m2 * xs + t2 into ys
         break

      case pX2 is not pX1 and pX4 is pX3
         put (pY2 - pY1) / (pX2 - pX1) into m1
         put - (m1 * pX1 - pY1) into t1
         put pX4 into xs
         put m1 * xs + t1 into ys
         break

      case pX2 is pX1 and pX4 is pX3 and pX4 is pX2
         put pX4 into xs
         put pY4 into ys
         --- pY4 ist einfach so gewählt, müsste man noch schaun was man da dann nimmt.
         break
   end switch
   --parallel lines have no intersection point
   --hier eventuell prüfen ob die ranges sich überlappen

   if m1 = m2 then
      if getSlope(pX1, pY1, pX2, pY2) = getSlope(pX3, pY3, pX4, pY4) then
         return "parallel"
       else
         return closestPointOnLine(pX1, pY1, pX2, pY2, pX3, pY3)
      end if
   end if

   return trunc(xs), trunc(ys)
end lineIntersectionPoint


function polyCollide pPointlist1, pPointlist2, pMethod
   local tFirstPoint = 0, tFourthPoint, tLineCounter, tLineCounter2
   local tP1x, tP1y, tP2x, tP2y
   local tP3x, tP3y, tP4x, tP4y
   local tSecondPoint, t, tTest1, tTest2
   local theLine, tThirdpoint, x, xx, y, yy

   repeat for each line tSecondPoint in pPointlist1
      add 1 to tFirstPoint

      if tFirstPoint = 1 then next repeat

      put item 1 of line (tFirstPoint - 1) of pPointlist1 into tP1x
      put item 2 of line (tFirstPoint - 1) of pPointlist1 into tP1y
      put item 1 of tSecondPoint into tP2x
      put item 2 of tSecondPoint into tP2y
      put 0 into tThirdpoint

      repeat for each line tFourthPoint in pPointlist2
         add 1 to tThirdpoint

         if tThirdpoint = 1 then next repeat

         put item 1 of line (tThirdpoint - 1) of pPointlist2 into tP3x
         put item 2 of line (tThirdpoint - 1) of pPointlist2 into tP3y
         put item 1 of tFourthPoint into tP4x
         put item 2 of tFourthPoint into tP4y
         put (tP1y - tP2y) into xx
         put (tP2x - tP1x) into yy

         repeat for each line t in pPointlist1
            put item 1 of t * xx + item 2 of t * yy & comma after tTest1
         end repeat

         repeat for each line t in pPointlist2
            put item 1 of t * xx + item 2 of t * yy & comma after tTest2
         end repeat

         if the last char of tTest1 = "," then delete char - 1 of tTest1
         if the last char of tTest2 = "," then delete char - 1 of tTest2
         if min(tTest2) > max(tTest1) or min(tTest1) > max(tTest2) then
            return false
         end if

         put empty into tTest1
         put empty into tTest2
      end repeat
   end repeat

   switch pMethod
      case "SAT"
         return true
         break

      case "pip"
         repeat for each line theLine in pPointlist1
            put item 1 of theLine into x
            put item 2 of theLine into y
            if pointInPoly(x, y, pPointlist2) then return true
         end repeat

         repeat for each line theLine in pPointlist2
            put item 1 of theLine into x
            put item 2 of theLine into y
            if pointInPoly(x, y, pPointlist1) then return true
         end repeat

         return false
         break

      default
         put 0 into tLineCounter

         repeat for each line tSecondPoint in pPointlist1
            add 1 to tLineCounter

            if tLineCounter = 1 then next repeat

            put 0 into tLineCounter2

            repeat for each line tFourthPoint in pPointlist2
               add 1 to tLineCounter2

               if tLineCounter2 = 1 then next repeat

               if item 1 of lineSegmentIntersectionPoint(line (tLineCounter - 1) of pPointlist1, tSecondPoint, line (tLineCounter2 - 1) of pPointlist2, tFourthPoint) is a number then
                  --put lineSegmentintersectionPoint(line counter-1 of pPointlist1,tSecondPoint1,line counter2-1 of pPointlist2,tFourthPoint)into xyz
                  return true
               end if
            end repeat
         end repeat
         return false
         break
   end switch

end polyCollide

--end added in 1.5

private function superFormula m, n1, n2, n3, phi, a, b
   local i, r, t1, t2
   local tParameters, x, y

   put m, n1, n2, n3, phi, a, b into tParameters

   repeat with i = 1 to the number of items of tParameters
      if item i of tParameters is not a number then
         return "Error: All Parameters must be numbers!"
      end if
   end repeat

   put cos(m * phi / 4) / a into t1
   put abs(t1) into t1
   put (t1) ^ n2 into t1

   put sin(m * phi / 4) / b into t2
   put abs(t2) into t2
   put (t2) ^ n3 into t2

   put (t1 + t2) ^(1 / n1) into r
   if abs(r) = 0 then
      put 0 into x
      put 0 into y
    else
      put 1 / r into r
      put r * cos(phi) into x
      put r * sin(phi) into y
   end if

   return round(x), round(y)
end superFormula

//FIXME: Convert this to a command that uses the aeMoveTo mechanism
//TODO: moveCircular pLongId, centerX, centerY, startAngle, duracion un # o inf para siempre, tipo mov
on moveCircular
   local tLoc, tLongId, tMoveCircularArray
   
   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveCircular") into tMoveCircularArray
   put the loc of tLongId into tLoc
   
   --The handler creates a customPropertySet "moveCircular" for the target
   --It sets the following custom properties of the target in that customPropertySet
   --centerX is the X coordinate of the circle
   --centerY is the Y coordinate of the circle
   --tAngle is the center angle of the circle
   --isRadius is the radius
   
   --If the custom properties are not set yet,
   --we need to initialize them first
   
   --default speed is 1
   if tMoveCircularArray["step"] is empty then put 1 into tMoveCircularArray["step"]
   
   --default x-location is item 1 of the loc of the target
   if tMoveCircularArray["centerX"] is empty then put item 1 of tLoc into tMoveCircularArray["centerX"]
   
   --default y location is item 2 of the loc of the target
   if tMoveCircularArray["centerY"] is empty then put item 2 of tLoc into tMoveCircularArray["centerY"]
   
   --default angle is 360 degrees
   if tMoveCircularArray["angle"] is empty then put 360 into tMoveCircularArray["angle"]
   
   --default radius is 50 pixel
   if tMoveCircularArray["radius"] is empty then put 50 into tMoveCircularArray["radius"]
   
   --calculate the next angle
   put tMoveCircularArray["angle"] + tMoveCircularArray["step"] into tMoveCircularArray["angle"]
   
   if tMoveCircularArray["angle"] >= 360 or tMoveCircularArray["angle"] < 0 then
      put tMoveCircularArray["angle"] mod 360 into tMoveCircularArray["angle"]
   end if
   
   _setAnimationEngine tLongId, "moveCircular", tMoveCircularArray
   
   --now calculate the new location.
   set the loc of tLongId to pointOnCircle((tMoveCircularArray["centerX"], tMoveCircularArray["centerY"], tMoveCircularArray["angle"], tMoveCircularArray["radius"]))
end moveCircular


on moveCircularReversePath
   local tLongId, tMoveCircularArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveCircular") into tMoveCircularArray

   if tMoveCircularArray is not an array then exit moveCircularReversePath

   put tMoveCircularArray["step"] * - 1 into tMoveCircularArray["step"]
   _setAnimationEngine tLongId, "moveCircular", tMoveCircularArray

end moveCircularReversePath


setProp moveCircularReversePath
   moveCircularReversePath
   exit moveCircularReversePath
end moveCircularReversePath


on moveElliptical
   local tLoc, tLongId, tMoveEllipticalArray, tCenterX, tCenterY

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveElliptical") into tMoveEllipticalArray
   put the loc of tLongId into tLoc

   --The handler creates a customPropertySet "moveElliptical" for the target
   --It sets the following custom properties of the target
   --cX is the X coordinate of the ellipse center
   --cY is the Y coordinate of the ellipse center
   --isAngle is the elipse center angle
   --radiusX is the radius in x-direction
   --radiusY is the radius in y-direction

   --if the custom properties of the target are not set yet,
   --we need to initialize them first

   --default speed is 1
   if tMoveEllipticalArray["step"] is not an integer then
      put 1 into tMoveEllipticalArray["step"]
   end if

   --default x-location is item 1 of the location of the target
   if tMoveEllipticalArray["centerX"] is not a number then
      put item 1 of tLoc into tMoveEllipticalArray["centerX"]
   end if

   --default y-location is item 2 of the location of the target
   if tMoveEllipticalArray["centerY"] is not a number then
      put item 2 of tLoc into tMoveEllipticalArray["centerY"]
   end if

   --default center angle is 360 degrees
   if tMoveEllipticalArray["angle"] is not a number then
      put 360 into tMoveEllipticalArray["angle"]
   end if

   --default radiusX is 80 pixel
   if tMoveEllipticalArray["radiusX"] is not a number then
      put 80 into tMoveEllipticalArray["radiusX"]
   end if

   --default radiusY is 50 pixel
   if tMoveEllipticalArray["radiusY"] is not a number then
      put 50 into tMoveEllipticalArray["radiusY"]
   end if

   --calculate the next angle
   put tMoveEllipticalArray["angle"] + tMoveEllipticalArray["step"] into tMoveEllipticalArray["angle"]
   if tMoveEllipticalArray["angle"] >= 360 then
      put 0 into tMoveEllipticalArray["angle"]
   end if

   --now calculate the new location.
   _setAnimationEngine tLongId, "moveElliptical", tMoveEllipticalArray


   set the loc of the target to pointOnEllipse((tMoveEllipticalArray["radiusX"], tMoveEllipticalArray["radiusY"], tMoveEllipticalArray["angle"], tMoveEllipticalArray["radiusX"], tMoveEllipticalArray["radiusY"]))
end moveElliptical


on moveEllipticalReversePath
   local tLongId, tMoveEllipticalArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveElliptical") into tMoveEllipticalArray

   if tMoveEllipticalArray["step"] is a number then
      put tMoveEllipticalArray["step"] * - 1 into tMoveEllipticalArray["step"]
      _setAnimationEngine tLongId, "moveElliptical", tMoveEllipticalArray
   end if
end moveEllipticalReversePath


on moveLinear
   local tLongId, tMoveLinearArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveLinear") into tMoveLinearArray

   if tMoveLinearArray["startPoint"] is not a point then put 0, 0 into tMoveLinearArray["startPoint"]
   if tMoveLinearArray["endPoint"] is not a point then put 100, 100 into tMoveLinearArray["endPoint"]
   if tMoveLinearArray["distance"] is not a number then put 0 into tMoveLinearArray["distance"]
   if tMoveLinearArray["step"] is not a number then put 1 into tMoveLinearArray["step"]
   if tMoveLinearArray["step"] < 0 then put tMoveLinearArray["step"] * - 1 into tMoveLinearArray["step"]

   put tMoveLinearArray["distance"] + tMoveLinearArray["step"] into tMoveLinearArray["distance"]

   if tMoveLinearArray["distance"] < distance(tMoveLinearArray["startPoint"], tMoveLinearArray["endPoint"]) then
      set the loc of tLongId to (pointOnLine(tMoveLinearArray["startPoint"], tMoveLinearArray["endPoint"], tMoveLinearArray["distance"]))

    else
      set the loc of tLongId to (pointOnLine(tMoveLinearArray["startPoint"], tMoveLinearArray["endPoint"], distance(tMoveLinearArray["startPoint"], tMoveLinearArray["endPoint"])))

      put 0 into tMoveLinearArray["distance"]
      put true into tMoveLinearArray["moveDone"]

      dispatch "moveLinearMoveDone" to tLongId

      if tMoveLinearArray["pingPong"] is true then
         moveLinearReversePath
         put false into tMoveLinearArray["moveDone"]
      end if
   end if

   _setAnimationEngine tLongId, "moveLinear", tMoveLinearArray
end moveLinear


on moveLinearReversePath
   local tLongId, tMoveLinearArray, tSwapStartPointAndEndPoint

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "movelinear") into tMoveLinearArray

   put tMoveLinearArray["endPoint"] into tSwapStartPointAndEndPoint
   put tMoveLinearArray["startPoint"] into tMoveLinearArray["endPoint"]
   put tSwapStartPointAndEndPoint into tMoveLinearArray["startPoint"]

   _setAnimationEngine tLongId, "movelinear", tMoveLinearArray
end moveLinearReversePath


on movePolygonal
   local tLongId, tMovePolygonalArray, tNewCurrent, tOldDistance

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "movePolygonal") into tMovePolygonalArray

   # CurrentPoints
   if tMovePolygonalArray["currentPoints"] is empty
   then put 0, 0 & cr & 100, 100 & cr & 100, 0 into tMovePolygonalArray["currentPoints"]

   # Current
   if tMovePolygonalArray["current"] is not an integer or tMovePolygonalArray["current"] < 2 then put 2 into tMovePolygonalArray["current"]

   if tMovePolygonalArray["current"] > the number of lines of tMovePolygonalArray["currentPoints"] then
      put tMovePolygonalArray["current"] mod the number of lines of tMovePolygonalArray["currentPoints"] into tNewCurrent
      if tNewCurrent < 2 then put 2 into tNewCurrent
      if tNewCurrent > the number of lines of tMovePolygonalArray["currentPoints"] then put the number of lines of tMovePolygonalArray["currentPoints"] into tNewCurrent
      put tNewCurrent into tMovePolygonalArray["current"]
   end if
   # distance
   if tMovePolygonalArray["distance"] is empty then
      put 0 into tMovePolygonalArray["distance"]
   end if
   # step
   if tMovePolygonalArray["step"] is empty then
      put 1 into tMovePolygonalArray["step"]
   end if

   if tMovePolygonalArray["step"] < 0 then
      put tMovePolygonalArray["step"] * - 1 into tMovePolygonalArray["step"]
   end if

   put line (tMovePolygonalArray["current"] - 1) of tMovePolygonalArray["currentPoints"] into tMovePolygonalArray["startPoint"]
   put line (tMovePolygonalArray["current"]) of tMovePolygonalArray["currentPoints"] into tMovePolygonalArray["endPoint"]
   put tMovePolygonalArray["distance"] + tMovePolygonalArray["step"] into tMovePolygonalArray["distance"]

   _setAnimationEngine tLongId, "movePolygonal", tMovePolygonalArray

   if tMovePolygonalArray["distance"] < distance(tMovePolygonalArray["startPoint"], tMovePolygonalArray["endPoint"]) then
      set the loc of tLongId to (pointOnLine(tMovePolygonalArray["startPoint"], tMovePolygonalArray["endPoint"], tMovePolygonalArray["distance"]))
    else
      put tMovePolygonalArray["distance"] into tOldDistance
      repeat
         --set the loc of the target to (tMovePolygonalArray[ "endPoint"] of the target)
         put tOldDistance - distance(tMovePolygonalArray["startPoint"], tMovePolygonalArray["endPoint"]) into tOldDistance

         if tOldDistance > 0 then
            --put oldDistance*-1 into olddistance
            put tOldDistance into tMovePolygonalArray["distance"]

            if tMovePolygonalArray["current"] < the number of lines of tMovePolygonalArray["currentPoints"] then
               put tMovePolygonalArray["current"] + 1 into tMovePolygonalArray["current"]

             else
               put true into tMovePolygonalArray["moveDone"]
               dispatch "movePolygonalMoveDone" to tLongId
               put 2 into tMovePolygonalArray["current"]
               _setAnimationEngine tLongId, "movePolygonal", tMovePolygonalArray
               exit movepolygonal
            end if

            put line (tMovePolygonalArray["current"] - 1) of tMovePolygonalArray["currentPoints"] into tMovePolygonalArray["startPoint"]
            put line (tMovePolygonalArray["current"]) of tMovePolygonalArray["currentPoints"] into tMovePolygonalArray["endPoint"]
            _setAnimationEngine tLongId, "movePolygonal", tMovePolygonalArray

          else
            put line (tMovePolygonalArray["current"] - 1) of tMovePolygonalArray["currentPoints"] into tMovePolygonalArray["startPoint"]
            put line (tMovePolygonalArray["current"]) of tMovePolygonalArray["currentPoints"] into tMovePolygonalArray["endPoint"]
            put tOldDistance + distance(tMovePolygonalArray["startPoint"], tMovePolygonalArray["endPoint"]) into tMovePolygonalArray["distance"]
            set the loc of tLongId to pointOnLine(tMovePolygonalArray["startPoint"], tMovePolygonalArray["endPoint"], tMovePolygonalArray["distance"])
            _setAnimationEngine tLongId, "movePolygonal", tMovePolygonalArray
            exit repeat
         end if
      end repeat
   end if
end movePolygonal


on movePolygonalReversePath
   local tLongId, tMovePolygonalArray, tNewDist, tTestMe, tPoints

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "movePolygonal") into tMovePolygonalArray

   put tMovePolygonalArray["current"] into tTestMe
   put tMovePolygonalArray["currentpoints"] into tPoints
   put tMovePolygonalArray["reversedPoints"] into tMovePolygonalArray["currentpoints"]
   put tPoints into tMovePolygonalArray["reversedPoints"]
   put (the number of lines of tPoints - tTestMe) + 2 into tMovePolygonalArray["current"]
   put tMovePolygonalArray["distance"] into tNewDist
   put distance(tMovePolygonalArray["startPoint"], tMovePolygonalArray["endPoint"]) - tNewdist into tMovePolygonalArray["distance"]
end movePolygonalReversePath


setProp superShape pValue
   local tOldloc, phi, tCallBack, tPoints, tLoops, tLongId
   //TODO: Investigate and put a more communicative name to these variables
   local m, n1, n2, n3, a, b, i

   put the long id of the target into tLongId

   if first word of tLongId = "graphic" then
      set the style of tLongId to "curve"

      put empty into tPoints
      put item 1 of pValue into m
      put item 2 of pValue into n1
      put item 3 of pValue into n2
      put item 4 of pValue into n3
      put item 5 of pValue into a
      put item 6 of pValue into b
      put item 7 of pValue into tLoops

      if m, n1, n2, n3 is not a rectangle or a, b is not a point or tLoops is a number
      then return "Error: syntax is set the supershape of graphic " & quote & "yourGraphic" & quote & " to m,n1,n2,n3,xScale,yScale,loops"

      repeat with i = 1 to tLoops
         put i * ((pi * 2) / tLoops) into phi
         put phi * 180 / pi into phi
         put superFormula(m, n1, n2, n3, phi, a, b) & cr after tPoints
         put tLoops - i into tCallBack

         dispatch "superShapeCallBack" to tLongId with tCallBack
      end repeat

      delete the last line of tPoints
      put the loc of tLongId into tOldloc
      set the points of tLongId to tPoints
      set the loc of tLongId to tOldloc
      pass supershape
    else
      return "Supershape only works for graphics"
   end if
end superShape


setProp superPath pValue
   local tOldLoc, tPhi, tPoints, tLoops, tLongId
   //TODO: Investigate and put a more communicative name to these variables
   local a, b, i, m, n1, n2, n3

   put the long id of target into tLongId

   if word 1 of tLongId = "graphic" then
      set the style of tLongId to "curve"

      put empty into tPoints
      put 1 into n1
      put 1 into n2
      put 1 into n3
      put item 1 of pValue into m
      put item 2 of pValue into a
      put item 3 of pValue into b
      put 1400 into tLoops

      if m, a is not a point or b is not a number then
         return "Error: syntax is set the supershape of grc " & quote & "yourGraphic" & quote & " to m,xScale,yScale"
      end if

      repeat with i = 1 to tLoops
         put i * ((pi * 2) / tLoops) into tPhi
         --put tPhi*180/pi into tPhi
         if the last line of tPoints <> superFormula(m, n1, n2, n3, tPhi, a, b) then
            put superFormula(m, n1, n2, n3, tPhi, a, b) & cr after tPoints
         end if
      end repeat

      put line 1 of tPoints & cr after tPoints
      delete the last char of tPoints

      --repeat with i=the number of lines of tPoints down to 2
      --if line i of tPoints=line i-1 of tPoints then delete line i of tPoints
      --end repeat
      put the loc of tLongId into tOldLoc
      set the points of tLongId to tPoints
      set the loc of tLongId to tOldLoc
      pass superPath
    else
      return "Supershape only works for graphics"
   end if
end superPath


setProp spiral pValue
   local tAccuracy, tCenterX, tCenterY, i
   local tWinding, tAngle, tRadius, tPointList
   local tStep, tWindings

   if word 1 of the long id of the target = "graphic" then
      set the style of the long id of the target to "curve"

      put item 1 of pValue into tCenterX
      put item 2 of pValue into tCenterY
      put item 3 of pValue into tStep
      put item 4 of pValue into tWindings
      put item 5 of pValue into tAccuracy

      if tCenterX, tCenterY, tStep, tWindings is not a rectangle then
         return "Error: syntax is set the spiral of grc " & quote & "yourGraphic" & quote & " to centerX, centerY, step, windings, [high|low|draft]"
      end if

      if tAccuracy is a number then
         if tAccuracy < 1 then
            put 1 into tAccuracy
          else if tAccuracy > 36 then
            put 36 into tAccuracy
         end if
       else
         switch tAccuracy
            case "high"
               put 2 into tAccuracy
               break
            case "low"
               put 4 into tAccuracy
               break
            case "draft"
               put 36 into tAccuracy
               break
            default
               put 4 into tAccuracy
               break
         end switch
      end if

      put 0 into tWinding
      put 0 into tAngle
      put 0 into tRadius

      repeat until tWinding >= tWindings
         add tAccuracy to tAngle
         add tAccuracy / 360 to tWinding
         add tStep * tAccuracy to tRadius

         if tAngle >= 360 then
            put tAngle - 360 into tAngle
         end if

         put pointOnCircle(tCenterX, tCenterY, tAngle, tRadius) & cr after tPointList
      end repeat

      set the points of the target to tPointList
      pass spiral
    else
      return "Error: Target must be a graphic!"
   end if
end spiral


setProp constrainLinear pValue
   local tLongId, tParam1, tParam2, tParam3, tParam4

   put the long id of target into tLongId
   put item 1 of pValue into tParam1
   put item 2 of pValue into tParam2
   put item 3 of pValue into tParam3
   put item 4 of pValue into tParam4

   if tParam1, tParam2, tParam3, tParam4 is not a rectangle
   then return "Error : constrainLinear needs 4 parameters and all parameters must be numbers."

   _setAnimationEngine tLongId, "constrainRectangular", empty
   _setAnimationEngine tLongId, "constrainElliptical", empty
   _setAnimationEngine tLongId, "constrainCircular", empty

   pass constrainLinear
end constrainLinear


setProp constrainCircular pValue
   local tLongId, tParam1, tParam2, tParam3

   put the long id of target into tLongId
   put item 1 of pValue into tParam1
   put item 2 of pValue into tParam2
   put item 3 of pValue into tParam3

   if tParam1, tParam2 is not a point or tParam3 is not a number
   then return "Error : constrainCircular needs 3 parameters and all parameters must be numbers."

   _setAnimationEngine tLongId, "constrainRectangular", empty
   _setAnimationEngine tLongId, "constrainElliptical", empty
   _setAnimationEngine tLongId, "constrainLinear", empty

   pass constrainCircular
end constrainCircular


setProp constrainRectangular pValue
   local tLongId, tParam1, tParam2, tParam3, tParam4

   put the long id of target into tLongId
   put item 1 of pValue into tParam1
   put item 2 of pValue into tParam2
   put item 3 of pValue into tParam3
   put item 4 of pValue into tParam4

   if tParam1, tParam2, tParam3, tParam4 is not a rectangle
   then return "Error : constrainRectangular needs 4 parameters and all parameters must be numbers."

   _setAnimationEngine tLongId, "constrainCircular", empty
   _setAnimationEngine tLongId, "constrainElliptical", empty
   _setAnimationEngine tLongId, "constrainLinear", empty

   pass constrainRectangular
end constrainRectangular


setProp constrainElliptical pValue
   local tLongId, tParam1, tParam2, tParam3, tParam4

   put the long id of target into tLongId
   put item 1 of pValue into tParam1
   put item 2 of pValue into tParam2
   put item 3 of pValue into tParam3
   put item 4 of pValue into tParam4

   if tParam1, tParam2, tParam3, tParam4 is not a rectangle
   then return "Error : constrainElliptical needs 4 parameters and all parameters must be numbers."

   _setAnimationEngine tLongId, "constrainCircular", empty
   _setAnimationEngine tLongId, "constrainRectangular", empty
   _setAnimationEngine tLongId, "constrainLinear", empty

   pass constrainElliptical
end constrainElliptical


setProp aspectScale pValue
   local tLongId, tParam1, tParam2, tParam3, tParam4, tParam5, tAspectResize

   put the long id of target into tLongId
   put item 1 of pValue into tParam1
   put item 2 of pValue into tParam2
   put item 3 of pValue into tParam3
   put item 4 of pValue into tParam4
   put item 5 of pValue into tParam5

   put _aspectResize(pValue,(tParam1, tParam2, tParam3, tParam4)) into tAspectResize

   set the width of tLongId to item 1 of tAspectResize
   set the height of tLongId to item 2 of tAspectResize
   set the lockloc of tLongId to false
   set the loc of tLongId to tParam1 + (tParam3 - tParam1) / 2, tParam2 + (tParam4 - tParam2) / 2

   if tParam5 = "true" then
      set the lockloc of tLongId to true
    else if tParam5 = "false" then
      set the lockloc of tLongId to false
   end if
   pass aspectScale
end aspectScale


setProp movePolyGonal[whichKey] pValue
   local tVal, tLongId, tCounter, tReversePoints

   put the number of lines of pValue into tVal
   if whichKey = "pointlist" then
      put the long id of target into tLongId
      put - 1 into tCounter

      repeat for each line tLine in pValue
         add 1 to tCounter
         put line (tVal - tCounter) of pValue & cr after tReversePoints
      end repeat

      delete the last char of tReversePoints

      _setAnimationEngine tLongId, "reversedPoints", tReversePoints
      _setAnimationEngine tLongId, "currentpoints", pValue
      --beep
   end if
   pass movePolygonal
end movePolyGonal


-- circular easing
on moveCircularEaseIn pLongId, pNewValue, pDuration, pExponent
   local tMoveCircularlArray
   
   if there is not a pLongId then return "error"-- no existe el control pLongId //TODO: T
   if (pNewValue is not a number or pDuration is not a number) or \
         (pExponent is not a number and pExponent is not empty) then
      return "error: Parameter is not a number"
   end if
   
   put _getAnimationEngine(pLongId, "moveCircular") into tMoveCircularlArray
   if pExponent is empty then put 2 into pExponent
   put  tMoveCircularlArray["step"] into tMoveCircularlArray["easeStart"]
   put  pNewValue into tMoveCircularlArray["easeEnd"]
   put  pDuration into tMoveCircularlArray["easeDuration"]
   put  pExponent into tMoveCircularlArray["easeExponent"]
   put the milliseconds into tMoveCircularlArray["easeStartTime"]
   
   _setAnimationEngine pLongId, "moveCircular", tMoveCircularlArray
   
   _moveCircularChangeStepIn pLongId
end moveCircularEaseIn


# Reserved for internal use
on _moveCircularChangeStepIn pLongId
   local tMoveCircularlArray, tDuration, tElapsed, tEnd, tExponent, tMillisecs, tStart

   if there is not a pLongId then _moveCircularChangeStepIn

   put _getAnimationEngine(pLongId, "moveCircular") into tMoveCircularlArray
   
   put tMoveCircularlArray["easeStart"] into tStart
   put tMoveCircularlArray["easeEnd"] into tEnd
   put tMoveCircularlArray["easeDuration"] into tDuration
   put tMoveCircularlArray["easeExponent"] into tExponent
   put tMoveCircularlArray["easeStartTime"] into tMillisecs
   put the milliseconds - tMillisecs into tElapsed
   put aeEaseIn(tStart, tEnd, tDuration, tElapsed, tExponent) into tMoveCircularlArray["step"]

   _setAnimationEngine pLongId, "moveCircular", tMoveCircularlArray

   if tMoveCircularlArray["step"] is a number and tMoveCircularlArray["step"] <> tEnd then send "_moveCircularChangeStepIn pLongId" to me in 20 milliseconds
end _moveCircularChangeStepIn


on moveCircularEaseOut pNewValue, pDuration, pExponent
   local tLongId, tMoveCircularlArray

   if pNewValue is not a number or pDuration is not a number or (pExponent is not a number and pExponent is not empty) then
      return "error: Parameter is not a number"
   end if

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveCircular") into tMoveCircularlArray

   if pExponent is empty then put 2 into pExponent
   put tMoveCircularlArray["step"] into tMoveCircularlArray["easeStart"]
   put pNewValue into tMoveCircularlArray["easeEnd"]
   put pDuration into tMoveCircularlArray["easeDuration"]
   put pExponent into tMoveCircularlArray["easeExponent"]
   put the milliseconds into tMoveCircularlArray["easeStartTime"]
   _setAnimationEngine tLongId, "moveCircular", tMoveCircularlArray

   _moveCircularChangeStepOut tLongId
end moveCircularEaseOut


# Reserved for internal use
on _moveCircularChangeStepOut pLongId
   local tMoveCircularlArray, tDuration, tElapsed, tEnd, tExponent, tMillisecs, tStart

   if there is not a pLongId then exit _moveCircularChangeStepOut

   put _getAnimationEngine(pLongId, "moveCircular") into tMoveCircularlArray

   put tStart into tMoveCircularlArray["easeStart"]
   put tEnd into tMoveCircularlArray["easeEnd"]
   put tDuration into tMoveCircularlArray["easeDuration"]
   put tExponent into tMoveCircularlArray["easeExponent"]
   put tMillisecs into tMoveCircularlArray["easeStartTime"]
   put the milliseconds - tMillisecs into tElapsed
   put aeEaseOut(tStart, tEnd, tDuration, tElapsed, tExponent) into tMoveCircularlArray["step"]
   _setAnimationEngine pLongId, "moveCircular", tMoveCircularlArray

   if tMoveCircularlArray["step"] is a number and tMoveCircularlArray["step"] <> tEnd then send "_moveCircularChangeStepOut pLongId" to me in 20 milliseconds
end _moveCircularChangeStepOut


on moveCircularEaseInOut pNewValue, pDuration, pExponent
   local tLongId, tMoveCircularlArray

   if pNewValue is not a number or pDuration is not a number or (pExponent is not a number and pExponent is not empty) then
      return "error: Parameter is not a number"
   end if

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveCircular") into tMoveCircularlArray

   if pExponent is empty then put 2 into pExponent
   put tMoveCircularlArray["step"] into tMoveCircularlArray["easeStart"]
   put pNewValue into tMoveCircularlArray["easeEnd"]
   put pDuration into tMoveCircularlArray["easeDuration"]
   put pExponent into tMoveCircularlArray["easeExponent"]
   put the milliseconds into tMoveCircularlArray["easeStartTime"]
   _setAnimationEngine tLongId, "moveCircular", tMoveCircularlArray

   _moveCircularChangeStepInOut tLongId
end moveCircularEaseInOut


# Reserved for internal use
on _moveCircularChangeStepInOut pLongId
   local tMoveCircularlArray, tElapsed

   if there is not a pLongId then exit _moveCircularChangeStepInOut

   put _getAnimationEngine(pLongId, "moveCircular") into tMoveCircularlArray
   put the milliseconds - tMoveCircularlArray["easeStartTime"] into tElapsed
   put aeEaseInOut(tMoveCircularlArray["easeStart"], tMoveCircularlArray["easeEnd"], tMoveCircularlArray["easeDuration"], tElapsed, tMoveCircularlArray["easeExponent"]) into tMoveCircularlArray["step"]

   _setAnimationEngine pLongId, "moveCircular", tMoveCircularlArray

   if tMoveCircularlArray["step"] is a number and tMoveCircularlArray["step"] <> tMoveCircularlArray["easeEnd"] then send "_moveCircularChangeStepInOut pLongId" to me in 20 milliseconds
end _moveCircularChangeStepInOut


-- elliptical easing
on moveEllipticalEaseIn pNewValue, pDuration, pExponent
   local tLongId, tMoveEllipticalArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveElliptical") into tMoveEllipticalArray

   if pExponent is empty then put 2 into pExponent
   if pNewValue is not a number or pDuration is not a number or pExponent is not a number
   then return "error: Parameter is not a number"

   put tMoveEllipticalArray["step"] into tMoveEllipticalArray["easeStart"]
   put pNewValue into tMoveEllipticalArray["easeEnd"]
   put pDuration into tMoveEllipticalArray["easeDuration"]
   put pExponent into tMoveEllipticalArray["easeExponent"]
   put the milliseconds into tMoveEllipticalArray["easeStartTime"]

   _setAnimationEngine tLongId, "moveElliptical", tMoveEllipticalArray

   _moveEllipticalChangeStepIn tLongId
end moveEllipticalEaseIn


# Reserved for internal use
on _moveEllipticalChangeStepIn pLongId
   local tMoveEllipticalArray, tDuration, tElapsed, tEnd, tExponent, tMillisecs, tStart

   if there is not a pLongId then exit _moveEllipticalChangeStepIn

   put _getAnimationEngine(pLongId, "moveElliptical") into tMoveEllipticalArray

   put tMoveEllipticalArray["easeStart"] into tStart
   put tMoveEllipticalArray["easeEnd"] into tEnd
   put tMoveEllipticalArray["easeDuration"] into tDuration
   put tMoveEllipticalArray["easeExponent"] into tExponent
   put tMoveEllipticalArray["easeStartTime"] into tMillisecs
   put the milliseconds - tMillisecs into tElapsed
   put aeEaseIn(tStart, tEnd, tDuration, tElapsed, tExponent) into tMoveEllipticalArray["step"]

   _setAnimationEngine pLongId, "moveElliptical", tMoveEllipticalArray

   if tMoveEllipticalArray["step"] is a number and tMoveEllipticalArray["step"] <> tEnd then send "_moveEllipticalChangeStepIn pLongId" to me in 20 milliseconds
end _moveEllipticalChangeStepIn


on moveEllipticalEaseOut pNewValue, pDuration, pExponent
   local tLongId, tMoveEllipticalArray

   if pExponent is empty then put 2 into pExponent
   if pNewValue is not a number or pDuration is not a number or pExponent is not a number
   then return "error: Parameter is not a number"

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveElliptical") into tMoveEllipticalArray

   put tMoveEllipticalArray["step"] into tMoveEllipticalArray["easeStart"]
   put pNewValue into tMoveEllipticalArray["easeEnd"]
   put pDuration into tMoveEllipticalArray["easeDuration"]
   put pExponent into tMoveEllipticalArray["easeExponent"]
   put the milliseconds into tMoveEllipticalArray["easeStartTime"]

   _moveEllipticalChangeStepOut tLongId
end moveEllipticalEaseOut

# Reserved for internal use
on _moveEllipticalChangeStepOut pLongId
   local tMoveEllipticalArray, tDuration, tElapsed, tEnd, tExponent, tMillisecs, tStart

   if there is a not pLongId then exit _moveEllipticalChangeStepOut
   put _getAnimationEngine(pLongId, "moveElliptical") into tMoveEllipticalArray

   put tMoveEllipticalArray["easeStart"] into tStart
   put tMoveEllipticalArray["easeEnd"] into tEnd
   put tMoveEllipticalArray["easeDuration"] into tDuration
   put tMoveEllipticalArray["easeExponent"] into tExponent
   put tMoveEllipticalArray["easeStartTime"] into tMillisecs
   put the milliseconds - tMillisecs into tElapsed

   put aeEaseOut(tStart, tEnd, tDuration, tElapsed, tExponent) into tMoveEllipticalArray["step"]
   _setAnimationEngine pLongId, "moveElliptical", tMoveEllipticalArray

   if tMoveEllipticalArray["step"] is a number and tMoveEllipticalArray["step"] <> tEnd then send "_moveEllipticalChangeStepOut pLongId" to me in 20 milliseconds
end _moveEllipticalChangeStepOut


on moveEllipticalEaseInOut pNewValue, pDuration, pExponent
   local tLongId, tMoveEllipticalArray

   if pExponent is empty then put 2 into pExponent
   if pNewValue is not a number or pDuration is not a number or pExponent is not a number
   then return "error: Parameter is not a number"

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveElliptical") into tMoveEllipticalArray

   put tMoveEllipticalArray["step"] into tMoveEllipticalArray["easeStart"]
   put pNewValue into tMoveEllipticalArray["easeEnd"]
   put pDuration into tMoveEllipticalArray["easeDuration"]
   put pExponent into tMoveEllipticalArray["easeExponent"]
   put the milliseconds into tMoveEllipticalArray["easeStartTime"]

   _setAnimationEngine tLongId, "moveElliptical", tMoveEllipticalArray

   dispatch "_moveEllipticalChangeStepInOut" to tLongId
end moveEllipticalEaseInOut


# Reserved for internal use
on _moveEllipticalChangeStepInOut pLongId
   local tMoveEllipticalArray, tDuration, tElapsed, tEnd, tExponent, tMillisecs, tStart

   if there is a not pLongId then exit _moveEllipticalChangeStepInOut
   put _getAnimationEngine(pLongId, "moveElliptical") into tMoveEllipticalArray

   put tMoveEllipticalArray["easeStart"] into tStart
   put tMoveEllipticalArray["easeEnd"] into tEnd
   put tMoveEllipticalArray["easeDuration"] into tDuration
   put tMoveEllipticalArray["easeExponent"] into tExponent
   put tMoveEllipticalArray["easeStartTime"] into tMillisecs
   put the milliseconds - tMillisecs into tElapsed
   put aeEaseInOut(tStart, tEnd, tDuration, tElapsed, tExponent) into tMoveEllipticalArray["step"]

   _setAnimationEngine pLongId, "moveElliptical", tMoveEllipticalArray

   if tMoveEllipticalArray["step"] is a number and tMoveEllipticalArray["step"] <> tEnd
   then send "_moveEllipticalChangeStepInOut pLongId" to me in 20 milliseconds
end _moveEllipticalChangeStepInOut


-- linear easing
command moveLinearEaseIn pNewValue, pDuration, pExponent
   local tLongId, tMoveLinearArray

   if pExponent is empty then put 2 into pExponent
   if pNewValue is not a number or pDuration is not a number or pExponent is not a number then
      return "error: Parameter is not a number"
   end if

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveLinear") into tMoveLinearArray

   put tMoveLinearArray["step"] into tMoveLinearArray["easeStart"]
   put pNewValue into tMoveLinearArray["easeEnd"]
   put pDuration into tMoveLinearArray["easeDuration"]
   put pExponent into tMoveLinearArray["easeExponent"]
   put the milliseconds into tMoveLinearArray["easeStartTime"]

   _moveLinearChangeStepIn tLongId
end moveLinearEaseIn


# Reserved for internal use
on _moveLinearChangeStepIn pLongId
   local tMoveLinearArray, tDuration, tElapsed, tEnd, tExponent, tMillisecs, tStart

   if there is not a pLongId then exit _moveLinearChangeStepIn
   put _getAnimationEngine(pLongId, "moveLinear") into tMoveLinearArray

   put tStart into tMoveLinearArray["easeStart"]
   put tEnd into tMoveLinearArray["easeEnd"]
   put tDuration into tMoveLinearArray["easeDuration"]
   put tExponent into tMoveLinearArray["easeExponent"]
   put tMillisecs into tMoveLinearArray["easeStartTime"]
   put the milliseconds - tMillisecs into tElapsed
   put aeEaseIn(tStart, tEnd, tDuration, tElapsed, tExponent) into tMoveLinearArray["step"]

   _setAnimationEngine pLongId, "moveLinear", tMoveLinearArray

   if tMoveLinearArray["step"] <> tEnd then send "_moveLinearChangeStepIn pLongId" to me in 20 milliseconds
end _moveLinearChangeStepIn


on moveLinearEaseOut pNewValue, pDuration, pExponent
   local tLongId, tMoveLinearArray

   _parameterFormat pNewValue, pDuration, pExponent, sTemp, sTemp, sTemp, sTemp, sTemp

   if pNewValue is not a number or pDuration is not a number or (pExponent is not a number and pExponent is not empty) then
      return "error: Parameter is not a number"
   end if

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveLinear") into tMoveLinearArray

   if pExponent is empty then put 2 into pExponent

   put the moveLinear["step"] of tLongId into tMoveLinearArray["easeStart"]
   put pNewValue into tMoveLinearArray["easeEnd"]
   put pDuration into tMoveLinearArray["easeDuration"]
   put pExponent into tMoveLinearArray["easeExponent"]
   put the milliseconds into tMoveLinearArray["easeStartTime"]

   _setAnimationEngine tLongId, "moveLinear", tMoveLinearArray

   dispatch "moveLinearChangeStepOut" to tLongId
end moveLinearEaseOut

# Reserved for internal use
on moveLinearChangeStepOut
   local tDuration, tElapsed, tEnd, tExponent, tMillisecs, tStart
   local tLongId, tMoveLinearArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveLinear") into tMoveLinearArray

   put tStart into tMoveLinearArray["easeStart"]
   put tEnd into tMoveLinearArray["easeEnd"]
   put tDuration into tMoveLinearArray["easeDuration"]
   put tExponent into tMoveLinearArray["easeExponent"]
   put tMillisecs into tMoveLinearArray["easeStartTime"]
   put the milliseconds - tMillisecs into tElapsed
   put aeEaseOut(tStart, tEnd, tDuration, tElapsed, tExponent) into tMoveLinearArray["step"]

   _setAnimationEngine tLongId, "moveLinear", tMoveLinearArray

   if tMoveLinearArray["step"] is a number and tMoveLinearArray["step"] <> tEnd then send "moveLinearChangeStepOut" to tLongId in 20 milliseconds
end moveLinearChangeStepOut


on moveLinearEaseInOut pNewValue, pDuration, pExponent
   local tLongId, tMoveLinearArray

   _parameterFormat pNewValue, pDuration, pExponent, sTemp, sTemp, sTemp, sTemp, sTemp

   if pNewValue is not a number or pDuration is not a number or (pExponent is not a number and pExponent is not empty) then
      return "error: Parameter is not a number"
   end if

   if pExponent is empty then put 2 into pExponent

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "moveLinear") into tMoveLinearArray

   put tMoveLinearArray["step"] into tMoveLinearArray["easeStart"]
   put pNewValue into tMoveLinearArray["easeEnd"]
   put pDuration into tMoveLinearArray["easeDuration"]
   put pExponent into tMoveLinearArray["easeExponent"]
   put the milliseconds into tMoveLinearArray["easeStartTime"]

   _setAnimationEngine tLongId, "moveLinear", tMoveLinearArray
   _moveLinearChangeStepInOut tLongId
end moveLinearEaseInOut


on _moveLinearChangeStepInOut pLongId
   local tLongId, tMoveLinearArray, tElapsed

   if there is not a pLongId then exit _moveLinearChangeStepInOut
   put _getAnimationEngine(pLongId, "moveLinear") into tMoveLinearArray

   put the milliseconds - tMoveLinearArray["easeStartTime"] into tElapsed
   put aeEaseInOut(tMoveLinearArray["easeStart"], tMoveLinearArray["easeEnd"], tMoveLinearArray["easeDuration"], tElapsed, tMoveLinearArray["easeExponent"]) into tMoveLinearArray["step"]

   _setAnimationEngine pLongId, "moveLinear", tMoveLinearArray
   if tMoveLinearArray["step"] <> tMoveLinearArray["easeEnd"] then send "_moveLinearChangeStepInOut pLongId" to me in 20 milliseconds
end _moveLinearChangeStepInOut


-- Polygonal easing
on movePolygonalEaseIn pNewValue, pDuration, pExponent
   local tLongId, tMovePolygonalArray

   _parameterFormat pNewValue, pDuration, pExponent, sTemp, sTemp, sTemp, sTemp, sTemp

   if pNewValue is not a number or pDuration is not a number or (pExponent is not a number and pExponent is not empty)
   then return "error: Parameter is not a number"

   if pExponent is empty then put 2 into pExponent
   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "movePolygonal") into tMovePolygonalArray

   put tMovePolygonalArray["step"] into tMovePolygonalArray["easeStart"]
   put pNewValue into tMovePolygonalArray["easeEnd"]
   put pDuration into tMovePolygonalArray["easeDuration"]
   put pExponent into tMovePolygonalArray["easeExponent"]
   put the milliseconds into tMovePolygonalArray["easeStartTime"]

   _setAnimationEngine tLongId, "movePolygonal", tMovePolygonalArray
   dispatch "movePolygonalChangeStepIn" to tLongId
end movePolygonalEaseIn


on movePolygonalChangeStepIn
   local tDuration, tElapsed, tEnd, tExponent, tMillisecs, tNewStep, tStart
   local tLongId, tMovePolygonalArray

   put the long id of target into tLongId
   put _getAnimationEngine(tLongId, "movePolygonal") into tMovePolygonalArray

   put the movePolygonal["easeStart"] of the target into tStart
   put the movePolygonal["easeEnd"] of the target into tEnd
   put the movePolygonal["easeDuration"] of the target into tDuration
   put the movePolygonal["easeExponent"] of the target into tExponent
   put the movePolygonal["easeStartTime"] of the target into tMillisecs
   put the milliseconds - tMillisecs into tElapsed
   put aeEaseIn(tStart, tEnd, tDuration, tElapsed, tExponent) into tNewStep
   set the movePolygonal["step"] of the target to tNewStep
   if tNewStep <> tEnd then send "movePolygonalChangeStepIn" to the target in 20 milliseconds

end movePolygonalChangeStepIn
#xxxxxxxxxxxxxxxxxxxxxV7xxxxxxxxxxxxxxxxxxxxxx#

on movePolygonalEaseOut pNewValue, pDuration, pExponent
   try
      if pNewValue is not a number or pDuration is not a number then
         return "error: Parameter is not a number"
         exit movePolygonalEaseOut
      end if
      if pExponent is not a number and pExponent is not empty then
         return "error: Parameter is not a number"
         exit movePolygonalEaseOut
      end if
      if pExponent is empty then put 2 into pExponent
      set the movePolygonal["easeStart"] of the target to the movePolygonal["step"] of the target
      set the movePolygonal["easeEnd"] of the target to pNewValue
      set the movePolygonal["easeDuration"] of the target to pDuration
      set the movePolygonal["easeExponent"] of the target to pExponent
      set the movePolygonal["easeStartTime"] of the target to the milliseconds
      send "movePolygonalChangeStepOut" to the target
   catch theError
      return theError
   end try

end movePolygonalEaseOut

on movePolygonalChangeStepOut
   local tDuration, tElapsed, tEnd, tExponent
   local tMillisecs, tNewStep, tStart
   try
      put the movePolygonal["easeStart"] of the target into tStart
      put the movePolygonal["easeEnd"] of the target into tEnd
      put the movePolygonal["easeDuration"] of the target into tDuration
      put the movePolygonal["easeExponent"] of the target into tExponent
      put the movePolygonal["easeStartTime"] of the target into tMillisecs
      put the milliseconds - tMillisecs into tElapsed
      put aeEaseOut(tStart, tEnd, tDuration, tElapsed, tExponent) into tNewStep
      set the movePolygonal["step"] of the target to tNewStep
      if tNewStep <> tEnd then send "movePolygonalChangeStepOut" to the target in 20 milliseconds
   catch theError
      return theError
   end try

end movePolygonalChangeStepOut

on movePolygonalEaseInOut pNewValue, pDuration, pExponent
   try
      if pNewValue is not a number or pDuration is not a number then
         return "error: Parameter is not a number"
         exit movePolygonalEaseInOut
      end if
      if pExponent is not a number and pExponent is not empty then
         return "error: Parameter is not a number"
         exit movePolygonalEaseInOut
      end if
      if pExponent is empty then put 2 into pExponent
      set the movePolygonal["easeStart"] of the target to the movePolygonal["step"] of the target
      set the movePolygonal["easeEnd"] of the target to pNewValue
      set the movePolygonal["easeDuration"] of the target to pDuration
      set the movePolygonal["easeExponent"] of the target to pExponent
      set the movePolygonal["easeStartTime"] of the target to the milliseconds
      send "movePolygonalChangeStepInOut" to the target
   catch theError
      return theError
   end try

end movePolygonalEaseInOut

on movePolygonalChangeStepInOut
   local bummba
   local tDuration, tElapsed, tEnd, tExponent
   local tMillisecs, tNewStep, tStart
   try
      put the movePolygonal["easeStart"] of the target into tStart
      put the movePolygonal["easeEnd"] of the target into tEnd
      put the movePolygonal["easeDuration"] of the target into tDuration
      put the movePolygonal["easeExponent"] of the target into tExponent
      put the movePolygonal["easeStartTime"] of the target into tMillisecs
      put the milliseconds - tMillisecs into tElapsed
      put aeEaseInOut(tStart, tEnd, tDuration, tElapsed, tExponent) into tNewStep
      set the movePolygonal["step"] of the target to tNewStep
      if tNewStep <> tEnd then send "movePolygonalChangeStepInOut" to the target in 20 milliseconds
   catch theError
      return theError
   end try

end movePolygonalChangeStepInOut


-- end added in 2.9

-- easing functions

function aeEaseIn pStart, pEnd, pDuration, pElapsedTime, pExponent
   try
      if pDuration <= pElapsedTime then return pEnd
      if pElapsedTime <= 0 then return pStart
      return pStart + ((pElapsedTime / pDuration) ^ pExponent) * (pEnd - pStart)
   catch theError
      return theError
   end try

end aeEaseIn

function aeEaseOut pStart, pEnd, pDuration, pElapsedTime, pExponent
   try
      if pDuration <= pElapsedTime then return pEnd
      if pElapsedTime <= 0 then return pStart
      return pStart + (1 - (1 - (pElapsedTime / pDuration)) ^ pExponent) * (pEnd - pStart)
   catch theError
      return theError
   end try

end aeEaseOut

function aeEaseInOut pStart, pEnd, pDuration, pElapsedTime, pExponent
   try
      if pDuration <= pElapsedTime then return pEnd
      if pElapsedTime <= 0 then return pStart
      if pElapsedTime / pDuration < 0.5 then
         return pStart + ((((pElapsedTime / pDuration) * 2) ^ pExponent) / 2) * (pEnd - pStart)
       else
         return pStart + (0.5 + _aeMathEaseOut((pElapsedTime / pDuration - 0.5) * 2, pExponent) / 2) * (pEnd - pStart)
      end if
   catch theError
      return theError
   end try

end aeEaseInOut

# Reserved for internal use
private function _aeMathEaseOut pR, pExponent
   return 1 - (1 - pR) ^ pExponent
end _aeMathEaseOut

-- isometric drawing and 3d

function isoToScreenX
   local i, pOriginX, pX, pY
   local pZ, tParameters, tXCartesian
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters <> 4 then
         return "Error: Syntax is isoToScreenX(pX,pY,pZ,pOriginX)"
         exit isoToScreenX
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit isoToScreenX
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX
      put item 2 of tParameters into pY
      put item 3 of tParameters into pZ
      put item 4 of tParameters into pOriginX
      -- generates x in cartesian coordinates from classic iso view
      --put (pX-pZ)*cos(0.46365) into tXCartesian
      --commented line might be needed for changeing cam position later on
      put (pX - pZ) * 0.894426 into tXCartesian
      return tXCartesian + pOriginX
   catch theError
      return theError
   end try
end isoToScreenX

function isoToScreenY
   local i, pOriginY, pX, pY
   local pZ, tParameters, tYCartesian
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters <> 4 then
         return "Error: Syntax is isoToScreenY(pX,pY,pZ,pOriginY)"
         exit isoToScreenY
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit isoToScreenY
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX
      put item 2 of tParameters into pY
      put item 3 of tParameters into pZ
      put item 4 of tParameters into pOriginY

      --put pY+(pX+pZ)*sin(0.46365) into tYCartesian
      put pY + (pX + pZ) * 0.447216 into tYCartesian
      return - tYCartesian + pOriginY
   catch theError
      return theError
   end try
end isoToScreenY

function isoToScreen
   local i, pOriginX, pOriginY, pX
   local pY, pZ, tParameters
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters <> 5 then
         return "Error: Syntax is isoToScreen(pX,pY,pZ,pOriginX,pOriginY)"
         exit isoToScreen
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit isoToScreen
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX
      put item 2 of tParameters into pY
      put item 3 of tParameters into pZ
      put item 4 of tParameters into pOriginX
      put item 5 of tParameters into pOriginY
      return round(isoToScreenX(pX, pY, pZ, pOriginX)), round(isoToScreenY(pX, pY, pZ, pOriginY))
   catch theError
      return theError
   end try
end isoToScreen

on drawIsoLine
   local i, pOriginX, pOriginY, pX1
   local pX2, pY1, pY2, pZ1
   local pZ2, tParameters, tPointList
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters <> 8 then
         return "Error: Syntax is drawIsoLine pX1,pY1,pZ1,pX2,pY2,pZ2,pOriginX,pOriginY"
         exit drawIsoLine
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit drawIsoLine
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX1
      put item 2 of tParameters into pY1
      put item 3 of tParameters into pZ1
      put item 4 of tParameters into pX2
      put item 5 of tParameters into pY2
      put item 6 of tParameters into pZ2
      put item 7 of tParameters into pOriginX
      put item 8 of tParameters into pOriginY
      put isoToScreen(pX1, pY1, pZ1, pOriginX, pOriginY) into tPointList
      put cr after tPointList
      put isoToScreen(pX2, pY2, pZ2, pOriginX, pOriginY) after tPointList
      create grc "isoLine"
      set the style of it to "curve"
      set the points of it to tPointList
   catch theError
      return theError
   end try
end drawIsoLine

on drawIsoBox
   local i, pA, pB, pC
   local pointlist, pOriginX, pOriginY, pX
   local pY, pZ, tParameters
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters <> 8 then
         return "Error: Syntax is drawIsoBox(pX,pY,pZ,pA,pB,pC,pOriginX,pOriginY)"
         exit drawIsoBox
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit drawIsoBox
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX
      put item 2 of tParameters into pY
      put item 3 of tParameters into pZ
      put item 4 of tParameters into pA
      put item 5 of tParameters into pB
      put item 6 of tParameters into pC
      put item 7 of tParameters into pOriginX
      put item 8 of tParameters into pOriginY
      put isoToScreen(pX, pY, pZ, pOriginX, pOriginY) & cr into pointlist
      put isoToScreen(pX + pA, pY, pZ, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px + pa, py + pb, pz, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py + pb, pz, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py, pz, pOriginX, pOriginY) & cr after pointlist
      put cr & isoToScreen(px, py + pb, pz, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px + pa, py + pb, pz, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px + pa, py + pb, pz + pc, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py + pb, pz + pc, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py + pb, pz, pOriginX, pOriginY) & cr after pointlist
      put cr & isoToScreen(px, py, pz, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py + pb, pz, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py + pb, pz + pc, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py, pz + pc, pOriginX, pOriginY) & cr after pointlist
      put isoToScreen(px, py, pz, pOriginX, pOriginY) & cr after pointlist
      create grc "isoBox"
      set the style of it to "curve"
      set the points of it to pointList
   catch theError
      return theError
   end try
end drawIsoBox

function rotateIsoPoint
   local cX, cY, cZ, i
   local newX, newY, newZ, pFocalLength
   local pX, pXRotation, pY, pYRotation
   local pZ, pZRotation, sX, sY
   local sZ, tParameters, xY, xZ
   local yX, yZ, zX, zY
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters < 6 then
         return "Error: Syntax is rotateIsoPoint(pX,pY,pZ,pXRotation,pYrotation,pZrotation)"
         exit rotateIsoPoint
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit rotateIsoPoint
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX
      put item 2 of tParameters into pY
      put item 3 of tParameters into pZ
      put item 4 of tParameters into pXRotation
      put item 5 of tParameters into pYRotation
      put item 6 of tParameters into pZRotation
      put item 7 of tParameters into pFocalLength
      put pXrotation * pi / 180 into pXrotation
      put pYrotation * pi / 180 into pYrotation
      put pZrotation * pi / 180 into pZrotation
      put sin(pXRotation) into sX
      put cos(pXRotation) into cX
      put sin(pYRotation) into sY
      put cos(pYRotation) into cY
      put sin(pZRotation) into sZ
      put cos(pZRotation) into cZ
      -- rotation around x
      put cx * pY - sx * pZ into xY
      put sx * pY + cx * pZ into xZ
      -- rotation around y
      put cy * xz - sy * pX into yZ
      put sy * xz + cy * pX into yX
      -- rotation around z
      put cz * yx - sz * xy into zX
      put sz * yx + cz * xy into zY

      put zX into newX
      put zY into newY
      put yZ into newZ

      return newX, newY, newZ
   catch theError
      return theError
   end try
end rotateIsoPoint

function ae3dConvertToScreen
   local i, pFocalLength, pOriginX, pOriginy
   local pX, pY, pZ, tParameters
   local tScalefactor, tXCartesian, tYCartesian
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters < 5 then
         return "Error: Syntax is ae3dConvertToScreen(pX,pY,pZ,pOriginX,pOriginY[,pFocalLength])"
         exit ae3dConvertToScreen
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit ae3dConvertToScreen
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX
      put item 2 of tParameters into pY
      put item 3 of tParameters into pZ
      put item 4 of tParameters into pOriginX
      put item 5 of tParameters into pOriginy
      put item 6 of tParameters into pFocalLength
      if pFocalLength is empty then put 300 into pFocalLength
      put ae3dScaleRatio(pZ, pFocalLength) into tScalefactor
      put px * tScalefactor into tXCartesian
      put pY * tScalefactor into tYCartesian
      return round(tXCartesian + pOriginX), round(- tYCartesian + pOriginY)
   catch theError
      return theError
   end try
end ae3dConvertToScreen

function rotate3DPoint
   local cX, cY, cZ, i
   local newX, newY, newZ, pFocalLength
   local pX, pXRotation, pY, pYRotation
   local pZ, pZRotation, tScalefactor, sX
   local sY, sZ, tParameters, xY
   local xZ, yX, yZ, zX
   local zY
   try

      repeat with i = 1 to paramcount()
         if i < paramcount() then
            put param(i) & "," after tParameters
          else
            put param(i) after tParameters
         end if
      end repeat
      --check syntax
      if the number of items of tParameters < 6 then
         return "Error: Syntax is rotate3DPoint(pX,pY,pZ,pXRotation,pYrotation,pZrotation[,pFocalLength])"
         exit rotate3DPoint
      end if
      --check syntax
      repeat with i = 1 to the number of items of tParameters
         if item i of tParameters is not a number then
            return "Error: All Parameters must be numbers!"
            exit rotate3DPoint
            exit repeat
         end if
      end repeat
      put item 1 of tParameters into pX
      put item 2 of tParameters into pY
      put item 3 of tParameters into pZ
      put item 4 of tParameters into pXRotation
      put item 5 of tParameters into pYRotation
      put item 6 of tParameters into pZRotation
      put item 7 of tParameters into pFocalLength
      if pFocalLength is empty then put 300 into pFocalLength
      put pXrotation * pi / 180 into pXrotation
      put pYrotation * pi / 180 into pYrotation
      put pZrotation * pi / 180 into pZrotation
      put sin(pXRotation) into sX
      put cos(pXRotation) into cX
      put sin(pYRotation) into sY
      put cos(pYRotation) into cY
      put sin(pZRotation) into sZ
      put cos(pZRotation) into cZ
      -- rotation around x
      put cx * pY - sx * pZ into xY
      put sx * pY + cx * pZ into xZ
      -- rotation around y
      put cy * xz - sy * pX into yZ
      put sy * xz + cy * pX into yX
      -- rotation around z
      put cz * yx - sz * xy into zX
      put sz * yx + cz * xy into zY
      put pfocalLength / (pfocalLength + yz) into tScalefactor
      put zX * tScalefactor into newX
      put zY * tScalefactor into newY
      put yZ into newZ

      return newX, newY, newZ
   catch theError
      return theError
   end try
end rotate3DPoint

function ae3dScaleRatio pZ, pFocalLength
   try
      return pFocalLength / (pFocalLength + pZ)
   catch theError
      return theError
   end try
end ae3dScaleRatio

-- unSupported

function AePrimitive_Box px, py, pz, pa, pb, pc
   local pointlist
   try
      put pX, pY, pZ & cr into pointlist
      put pX + pA, pY, pZ & cr after pointlist
      put px + pa, py + pb, pz & cr after pointlist
      put px, py + pb, pz & cr after pointlist
      put px, py, pz & cr after pointlist
      put cr & px, py + pb, pz & cr after pointlist
      put px + pa, py + pb, pz & cr after pointlist
      put px + pa, py + pb, pz + pc & cr after pointlist
      put px, py + pb, pz + pc & cr after pointlist
      put px, py + pb, pz & cr after pointlist
      put cr & px, py, pz & cr after pointlist
      put px, py + pb, pz & cr after pointlist
      put px, py + pb, pz + pc & cr after pointlist
      put px, py, pz + pc & cr after pointlist
      put px, py, pz & cr after pointlist
      return pointList
   catch theError
      return theError
   end try
end AePrimitive_Box

on draw3dBox pX, pY, pZ, pA, pB, pC, pOriginX, pOriginY, pXRot, pYrot, pZrot, pFocalLength
   local pointlist, pointlist2, theLine
   try
      put rotate3DPoint(pX, pY, pZ, pxRot, pYRot, pZRot, pFocalLength) & cr into pointlist
      put rotate3DPoint(pX + pA, pY, pZ, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px + pa, py + pb, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py + pb, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put cr & rotate3dpoint(px, py + pb, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px + pa, py + pb, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px + pa, py + pb, pz + pc, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py + pb, pz + pc, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py + pb, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put cr & rotate3dpoint(px, py, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py + pb, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py + pb, pz + pc, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py, pz + pc, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist
      put rotate3DPoint(px, py, pz, pxRot, pYRot, pZRot, pFocalLength) & cr after pointlist

      repeat for each line theLine in pointList
         if theLine is not empty then

            put ae3dConvertToScreen(item 1 of theLine, item 2 of theLine, item 3 of theLine, pOriginX, pOriginY, pFocalLength) & cr after pointlist2
          else
            put cr & cr after pointList2
         end if
      end repeat

      create grc "3dBox"
      set the style of it to "curve"
      set the points of it to pointList2
   catch theError
      return theError
   end try

end draw3dBox

on draw3dLine pX1, pY1, pZ1, pX2, pY2, pZ2, pOriginX, pOriginY, pViewAngle, pFocalLength
   try
      create grc "3dLine"
      set the style of it to "curve"
      set the points of it to ae3dConvertToScreen(pX1, pY1, pZ1, pOriginX, pOriginY, pviewAngle, pFocalLength) & cr & ae3dConvertToScreen(pX2, pY2, pZ2, pOriginX, pOriginY, pViewAngle, pFocalLength)
   catch theError
      return theError
   end try
end draw3dLine

-- 2.1 update

on aeChangeTextSize pChange
   local counter, newHTML, testItem, theHtml
   local theItem, theSize
   if pChange is not a number then
      return "Error: parameter must be a number!"
      exit aeChangeTextSize
   end if
   if there is no field the target then
      return "Error: Target must be a field!" && the target
      exit aeChangeTextSize
   end if
   put the htmltext of the target into theHtml
   if the effective textsize of the target + pChange < 8 then
      return "Smallest size reached"
      exit aeChangeTextSize
   end if
   set the textsize of the target to \
         the effective textsize of the target + pChange
   replace "size=" & quote with "size=" & numToChar(1500) in theHTML
   set the itemdel to numtochar(1500)
   if the number of items of theHTML <> 1 then
      put 0 into testItem
      repeat for each item theItem in theHTML
         add 1 to testItem
         if testItem <> 1 then
            put offset(quote, theitem) into counter
            put char 1 to counter - 1 of theItem into theSize
            put theSize + pChange into theSize
            if theSize < 8 then
               set the textsize of the target to \
                     the effective textsize of the target - pChange
               return "Smallest size reached!"
               exit aeChangeTextSize
            end if
            put theSize into char 1 to counter - 1 of theItem
            put quote & theItem after newHTML
          else
            put theItem into newHTML
            next repeat
         end if
      end repeat
      set the htmltext of the target to newHTML
   end if
   --put the htmlText of the target
end aeChangeTextSize

--> 2.9 _toplevel handlers

--> 2.9 moving stuff
local tAeEasing, tAEEasingCircular, sAEFrameRate, sAERealFrameRate, sAELockMoves

function aeGetAverageFrameRate
   if sAERealFrameRate is not empty then
      return sAERealFrameRate
    else
      if sAEFrameRate is not empty then
         return sAEFrameRate
      else return 0
   end if
end aeGetAverageFrameRate

on aeSetFrameRate pRate
   if pRate is not a number then
      aeResetFrameRate
      return "error: frame rate is not a number"
    else
      put pRate into sAEFrameRate
   end if
end aeSetFrameRate

private command aeResetFrameRate
   put 25 into sAEFrameRate
   put 25 into sAERealFrameRate
end aeResetFrameRate

on aeChangeAngleCircular
   local tControl, tX, tY, tRadius, tNewAngle, tDuration, tMethod, tParameters, tCurrentAngle, tDirection
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tX
   put item 3 of tParameters into tY
   put item 4 of tParameters into tRadius
   put item 5 of tParameters into tNewAngle
   put item 6 of tParameters into tDuration
   put item 7 of tParameters into tDirection
   put item 8 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if word 1 of the long name of tControl is "card" then return "error: can not move a card"
   if tX is not an integer then return "error:" && tX & "," & tY && "is not a valid point"
   if tY is not an integer then return "error:" && tX & "," & tY && "is not a valid point"
   if tRadius is not a number then return "error:" && tRadius && "is not a number (radius)"
   if tNewAngle is not a number then return "error:" && tNewAngle && "is not a number (newAngle)"
   if tDuration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tDuration && "is not a valid easing method. Must be in,out or inOut"
   put findAngleX(tX, tY, item 1 of the the loc of tControl, item 2 of the loc of tControl) into tCurrentAngle
   switch tDirection
      case "clockwise"
         if tNewAngle < tCurrentAngle then add 360 to tNewAngle
         break
      case "counterClockwise"
         if tNewAngle > tCurrentAngle then add 360 to tCurrentAngle
         break
   end switch
   if not sAELockMoves then
      put tX, tY, tDuration, tMethod, tCurrentAngle, tNewAngle, tRadius, the milliseconds into tAeEasingCircular[the long id of tControl]
      if "aeGeneral" is not in the pendingmessages then
         aeGeneral
      end if
    else
      put tX, tY, tDuration, tMethod, tCurrentAngle, tNewAngle, tRadius, "pending" into tAeEasingCircular[the long id of tControl]
   end if
end aeChangeAngleCircular

on aeMoveTo
   local tControl, tX, tY, tDuration, tMethod, tParameters

   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat

   put item 1 of tParameters into tControl
   put item 2 of tParameters into tX
   put item 3 of tParameters into tY
   put item 4 of tParameters into tDuration
   put item 5 of tParameters into tMethod

   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if word 1 of the long name of tControl is "card" then return "error: can not move a card"
   if tX is not an integer then return "error:" && tX & "," & tY && "is not a valid point"
   if tY is not an integer then return "error:" && tX & "," & tY && "is not a valid point"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tDuration && "is not a valid easing method. Must be in,out or inOut"
   if not sAELockMoves then
      put tX, tY, tDuration, tMethod, item 1 of the the loc of tControl, item 2 of the loc of tControl, the milliseconds into tAeEasing[the long id of tControl]
      if "aeGeneral" is not in the pendingmessages then
         aeGeneral
      end if
    else
      put tX, tY, tDuration, tMethod, item 1 of the the loc of tControl, item 2 of the loc of tControl, "pending" into tAeEasing[the long id of tControl]
   end if
end aeMoveTo

on aeLockMoves
   put true into sAELockMoves
end aeLockMoves

on aeUnlockMoves
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAEEasing
      if item 7 of tAEEasing[pControl] <> "pending" then next repeat
      put tNow into item 7 of tAEEasing[pControl]
   end repeat
   put false into sAeLockMoves
   if "aeGeneral" is not in the pendingmessages then aeGeneral
end aeUnlockMoves


# Reserved for internal use
on aeGeneral
   lock screen
   local tTimeLost, tFramesLost, tElapsed, tControls
   local tX, tY, tDuration, tMethod, tEndX, tStartX, tDestX, tStartY, tDestY, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTaken into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTaken
   --lock screen
   put the keys of tAEEasing into tControls
   repeat for each line pControl in tControls
      -- housekeeping!
      -- need to check if control really exists!
      if there is a pControl then
         send "aeEnterFrame" && "aeMoveTo" to pcontrol
         put item 1 of tAEEasing[pControl] into tDestX
         put item 2 of tAEEasing[pControl] into tDestY
         put item 3 of tAEEasing[pControl] into tDuration
         put item 4 of tAEEasing[pControl] into tMethod
         put item 5 of tAEEasing[pControl] into tStartX
         put item 6 of tAEEasing[pControl] into tStartY
         put item 7 of tAEEasing[pControl] into tStartTime
         if tStartTime = "pending" then next repeat
         switch tMethod
            case "in"
               put aeEaseIn(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 3) into tX
               put aeEaseIn(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 3) into ty
               break
            case "out"
               put aeEaseOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 3) into tX
               put aeEaseOut(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 3) into ty
               break
            case "inOut"
               put aeEaseInOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 3) into tX
               put aeEaseInOut(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 3) into ty
               break
            case "bounce"
               put aeBounceEaseOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime) into tX
               put aeBounceEaseOut(tStartY, tDestY, tDuration, the milliseconds - tStartTime) into ty
               break
            case "overshoot"
               put aeOverShootEaseOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime) into tX
               put aeOverShootEaseOut(tStartY, tDestY, tDuration, the milliseconds - tStartTime) into ty
               break
            default
               put aeEaseIn(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 1) into tX
               put aeEaseIn(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 1) into ty
               break
         end switch
         if the milliseconds - tStartTime < tDuration then
            set the loc of pControl to tX, tY
          else
            if tDestx, tDestY is a point then
               set the loc of pControl to tDestX, tDestY
            end if
            delete variable tAeEasing[pControl]
            dispatch "aeMoveDone" to pControl
         end if
         send "aeExitFrame" && "aeMoveTo" to pControl
       else
         delete variable tAeEasing[pControl]
      end if
   end repeat

   local tCenterX, tCenterY, tRadius, tStartAngle, tEndAngle, tNewAngle
   -- tX,tY,tDuration,tMethod,findAngleX(tX,tY,item 1 of the the loc of tControl,item 2 of the loc of tControl), "pending"
   put the keys of tAEEasingCircular into tControls
   repeat for each line pControl in tControls
      if there is a pControl then
         send "aeEnterFrame" && "aeChangeAngleCircular" to pcontrol
         put item 1 of tAEEasingCircular[pControl] into tCenterX
         put item 2 of tAEEasingCircular[pControl] into tCenterY
         put item 3 of tAEEasingCircular[pControl] into tDuration
         put item 4 of tAEEasingCircular[pControl] into tMethod
         put item 5 of tAEEasingCircular[pControl] into tStartAngle
         put item 6 of tAEEasingCircular[pControl] into tEndAngle
         put item 7 of tAEEasingCircular[pControl] into tRadius
         put item 8 of tAEEasingCircular[pControl] into tStartTime
         if tStartTime = "pending" then next repeat
         --      put tRadius
         --      exit to top
         switch tMethod
            case "in"
               put aeEaseIn(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 3) into tNewAngle
               break
            case "out"
               put aeEaseOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 3) into tNewAngle
               break
            case "inOut"
               put aeEaseInOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 3) into tNewAngle
               break
            case "bounce"
               put aeBounceEaseOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime) into tNewAngle
               break
            case "overshoot"
               put aeOverShootEaseOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime) into tNewAngle
               break
            default
               put aeEaseIn(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 1) into tNewAngle
               break
         end switch
         if the milliseconds - tStartTime < tDuration then
            set the loc of pControl to pointOnCircle(tCenterX, tCenterY, tNewAngle, tRadius)
          else
            if tDestx, tDestY is a point then
               set the loc of pControl to pointOnCircle(tCenterX, tCenterY, tEndAngle, tRadius)
            end if
            delete variable tAeEasingCircular[pControl]
            dispatch "aeMoveDone" to pControl
         end if
         send "aeExitFrame" && "aeChangeAngleCircular" to pControl
       else
         delete variable tAeEasingCircular[pControl]
      end if
   end repeat

   -- morphing
   put the keys of sAEMorphing into tControls
   repeat for each line pControl in tControls
      if there is a pControl then
         send "aeEnterFrame" && "aeMorphGraphic" to pControl
         if sAEMorphing[pControl]["StartTime"] <> "pending" then
            if the millisecs - sAEMorphing[pControl]["StartTime"] < sAEMorphing[pControl]["duration"] then
               --aeMorphPointlists pList1,pList2,pDuration,pCurrentTime,pEffect
               --put the millisecs & cr & aeMorphPointlists(sAEMorphing[pControl][ "p1"],sAEMorphing[pControl]["p2"],sAEMorphing[pControl]["duration"],the milliSecs -sAEMorphing[pControl]["StartTime"] , sAEMorphing[pControl]["Effect"]  )
               set the points of pControl to aeMorphPointlists(sAEMorphing[pControl]["p1"], sAEMorphing[pControl]["p2"], sAEMorphing[pControl]["duration"], the milliSecs - sAEMorphing[pControl]["StartTime"], sAEMorphing[pControl]["Effect"])
             else
               set the points of pControl to sAEMorphing[pControl]["p2"]
               delete variable sAEMorphing[pControl]
               dispatch "aeMorphDone" to pControl
            end if
         end if
         send "aeExitFrame" && "aeMorphGraphic" to pControl
       else
         delete variable sAEMorphing[pControl]
      end if
   end repeat

   --  sAEMorphGradientRamp
   put the keys of sAEMorphGradientRamp into tControls

   repeat for each line pControl in tControls
      if there is a pControl then
         send "aeEnterFrame" && "aeMorphGradient" to pControl
         if sAEMorphGradientRamp[pControl]["StartTime"] <> "pending" then
            if the millisecs - sAEMorphGradientRamp[pControl]["StartTime"] < sAEMorphGradientRamp[pControl]["duration"] then
               --aeMorphPointlists pList1,pList2,pDuration,pCurrentTime,pEffect
               set the fillGradient["ramp"] of pControl to aeMorphGradient(sAEMorphGradientRamp[pControl]["p1"], sAEMorphGradientRamp[pControl]["p2"], sAEMorphGradientRamp[pControl]["duration"], the milliSecs - sAEMorphGradientRamp[pControl]["StartTime"], sAEMorphGradientRamp[pControl]["Effect"])
             else
               set the fillGradient["ramp"] of pControl to sAEMorphGradientRamp[pControl]["p2"]
               delete variable sAEMorphGradientRamp[pControl]
               dispatch "aeMorphGradientDone" to pControl
            end if
         end if
         send "aeExitFrame" && "aeMorphGradient" to pControl
       else
         delete variable sAEMorphGradientRamp[pControl]
      end if
   end repeat

   -- rotate group

   put the keys of sAERotateGroup into tControls

   repeat for each line theGroup in tControls
      if there is a theGroup then
         send "aeEnterFrame" && "aeRotateGroup" to theGroup
         if sAERotateGroup[theGroup]["StartTime"] <> "pending" then
            put sAERotateGroup[theGroup]["duration"] into tDuration
            put sAERotateGroup[theGroup]["StartTime"] into tStartTime
            put sAERotateGroup[theGroup]["Effect"] into tMethod

            if the millisecs - sAERotateGroup[theGroup]["StartTime"] < tDuration then
               repeat for each line theControl in the keys of sAERotateGroup[theGroup]["controls"]

                  put sAERotateGroup[theGroup]["Angle"] + sAERotateGroup[theGroup]["controls"][theControl]["Angle"] into tEndAngle
                  put sAERotateGroup[theGroup]["controls"][theControl]["Angle"] into tStartAngle

                  switch tMethod
                     case "in"
                        put aeEaseIn(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 3) into tNewAngle
                        break
                     case "out"
                        put aeEaseOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 3) into tNewAngle
                        break
                     case "inOut"
                        put aeEaseInOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 3) into tNewAngle
                        break
                     case "bounce"
                        put aeBounceEaseOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime) into tNewAngle
                        break
                     case "overshoot"
                        put aeOverShootEaseOut(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime) into tNewAngle
                        break
                     default
                        put aeEaseIn(tStartAngle, tEndAngle, tDuration, the milliseconds - tStartTime, 1) into tNewAngle
                        break
                  end switch

                  /*
                  put item 1 of tParameters into centerX
                  put item 2 of tParameters into centerY
                  put item 3 of tParameters into isAngle
                  put item 4 of tParameters into isRadius
                  */

                  set the loc of theControl to pointOnCircle(sAERotateGroup[theGroup]["center"], tNewAngle, sAERotateGroup[theGroup]["controls"][theControl]["Distance"])
               end repeat

             else
               repeat for each line theControl in the keys of sAERotateGroup[theGroup]["controls"]
                  put sAERotateGroup[theGroup]["Angle"] + sAERotateGroup[theGroup]["controls"][theControl]["Angle"] into tEndAngle
                  set the loc of theControl to pointOnCircle(sAERotateGroup[theGroup]["center"], tEndAngle, sAERotateGroup[theGroup]["controls"][theControl]["Distance"])
               end repeat
               delete variable sAERotateGroup[theGroup]
            end if
         end if
       else
         delete variable sAERotateGroup[theGroup]
      end if
   end repeat

   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeEasing is not empty OR the keys of tAEEasingCircular is not empty OR the keys of sAEMorphing is not empty OR the keys of sAEMorphGradientRamp is not empty OR the keys of sAERotateGroup is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeGeneral" is not in the pendingmessages then
            send "aeGeneral" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeGeneral" is not in the pendingmessages then
            send "aeGeneral" to me in 5 millisecs
         end if
      end if
   end if
   --   wait 0 milliseconds with messages
end aeGeneral

on aeEnterFrame
   --
end aeEnterFrame

on aeExitFrame
   --
end aeExitFrame

on aeStopMoving tControl
   if tControl = "all" then
      delete variable tAEEasing
    else
      delete variable tAEEasing[the long id of tControl]
   end if
end aeStopMoving

--> 2.9 geometry stuff

function aeWithinEllipse
   -- params center of ellipse,xRadius,yRadius,testPoint
   local tX, tY, tRadX, tRadY, tX2, tY2, tParameters
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tX
   put item 2 of tParameters into tY
   put item 3 of tParameters into tRadX
   put item 4 of tParameters into tRadY
   put item 5 of tParameters into tX2
   put item 6 of tParameters into tY2
   if tx is not a number then return "error: x-loc of ellipse is not a number"
   if ty is not a number then return "error: y-loc of ellipse is not a number"
   if tradx is not a number then return "error: x-radius of ellipse is not a number"
   if trady is not a number then return "error: y-radius of ellipse is not a number"
   if tx2 is not a number then return "error: x-loc of point is not a number"
   if ty2 is not a number then return "error: y-loc of point is not a number"
   return (tX2 - tX) ^ 2 / tradx ^ 2 + (ty2 - ty) ^ 2 / trady ^ 2 <= 1
end aeWithinEllipse



--> 6.0 morph pointlists

on aeLockMorph
   put true into sAELockMorph
end aeLockMorph

on aeUnlockMorph
   put false into sAELockMorph
   if "aeGeneral" is not in the pendingMessages then
      aeGeneral
   end if
end aeUnlockMorph

on aeLockMorphGradientRamp
   put true into sAELockMorphGradientRamp
end aeLockMorphGradientRamp

on aeUnlockMorphGradientRamp
   put false into sAELockMorphGradientRamp
   if "aeGeneral" is not in the pendingMessages then
      aeGeneral
   end if
end aeUnlockMorphGradientRamp


on aeMorphGraphic pControl, pPointList1, pPointList2, pDuration, pEffect
   if sAEFrameRate is empty then aeResetFrameRate
   if there is no pControl then return "error:" && pControl && "is not a valid control or group or stack"
   if word 1 of the long name of pControl is not "graphic" then return "error: morphing only works for graphics"
   if the number of lines of pPointList1 <> the number of lines of pPointList2 then return "error: pointlists must have equal number of lines"
   if pDuration is not a number then return "error:" && pDuration && "is not a valid duration"
   if pEffect is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && pEffect && "is not a valid easing method. Must be in,out or inOut"
   put pPointList1 into sAEMorphing[the long id of pControl]["p1"]
   put pPointList2 into sAEMorphing[the long id of pControl]["p2"]
   put pDuration into sAEMorphing[the long id of pControl]["duration"]
   put pEffect into sAEMorphing[the long id of pControl]["Effect"]
   if not sAELockMorph then
      put the millisecs into sAEMorphing[the long id of pControl]["startTime"]
      if "aeGeneral" is not in the pendingmessages then
         aeGeneral
      end if
    else
      put "pending" into sAEMorphing[the long id of pControl]["startTime"]
   end if
end aeMorphGraphic

on aeMorphGradientRamp pControl, pPointList1, pPointList2, pDuration, pEffect
   if sAEFrameRate is empty then aeResetFrameRate
   if there is no pControl then return "error:" && pControl && "is not a valid control or group or stack"
   if word 1 of the long name of pControl is not "graphic" then return "error: morphing only works for graphics"
   if the number of lines of pPointList1 <> the number of lines of pPointList2 then return "error: pointlists must have equal number of lines"
   if pDuration is not a number then return "error:" && pDuration && "is not a valid duration"
   if pEffect is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && pEffect && "is not a valid easing method. Must be in,out or inOut"
   put pPointList1 into sAEMorphGradientRamp[the long id of pControl]["p1"]
   put pPointList2 into sAEMorphGradientRamp[the long id of pControl]["p2"]
   put pDuration into sAEMorphGradientRamp[the long id of pControl]["duration"]
   put pEffect into sAEMorphGradientRamp[the long id of pControl]["Effect"]
   if not sAELockMorphGradientRamp then
      put the millisecs into sAEMorphGradientRamp[the long id of pControl]["startTime"]
      if "aeGeneral" is not in the pendingmessages then
         aeGeneral
      end if
    else
      put "pending" into sAEMorphGradientRamp[the long id of pControl]["startTime"]
   end if
end aeMorphGradientRamp

function aeMorphPointlists pList1, pList2, pDuration, pCurrentTime, pEffect
   local tResultList, tCounter
   if the number of lines of pList1 <> the number of lines of pList2 then return "error: number of points in lists is not equal"
   repeat for each line theLine in pList1
      add 1 to tCounter
      if line tCounter of pList1 is empty or line tCounter of pList2 is empty then
         put cr after tResultList
         next repeat
      end if
      switch pEffect
         case "bounce"
            put aeBounceEaseOut(item 1 of line tCounter of pList1, item 1 of line tCounter of pList2, pDuration, pCurrentTime) & "," & aeBounceEaseOut(item 2 of line tCounter of pList1, item 2 of line tCounter of pList2, pDuration, pCurrentTime) & cr after tResultList
            break
         case "overShoot"
            put aeoverShootEaseOut(item 1 of line tCounter of pList1, item 1 of line tCounter of pList2, pDuration, pCurrentTime) & "," & aeOvershootEaseOut(item 2 of line tCounter of pList1, item 2 of line tCounter of pList2, pDuration, pCurrentTime) & cr after tResultList
            break
         case "in"
            put aeEaseIn(item 1 of line tCounter of pList1, item 1 of line tCounter of pList2, pDuration, pCurrentTime, 3) & "," & aeEaseIn(item 2 of line tCounter of pList1, item 2 of line tCounter of pList2, pDuration, pCurrentTime, 3) & cr after tResultList
            break
         case "out"
            put aeEaseOut(item 1 of line tCounter of pList1, item 1 of line tCounter of pList2, pDuration, pCurrentTime, 3) & "," & aeEaseOut(item 2 of line tCounter of pList1, item 2 of line tCounter of pList2, pDuration, pCurrentTime, 3) & cr after tResultList
            break
         case "inOut"
            put aeEaseInOut(item 1 of line tCounter of pList1, item 1 of line tCounter of pList2, pDuration, pCurrentTime, 3) & "," & aeEaseInOut(item 2 of line tCounter of pList1, item 2 of line tCounter of pList2, pDuration, pCurrentTime, 3) & cr after tResultList
            break
         default
            put aeEaseIn(item 1 of line tCounter of pList1, item 1 of line tCounter of pList2, pDuration, pCurrentTime, 2) & "," & aeEaseIn(item 2 of line tCounter of pList1, item 2 of line tCounter of pList2, pDuration, pCurrentTime, 2) & cr after tResultList
            break
      end switch
   end repeat
   delete char - 1 of tResultList
   return tResultList
end aeMorphPointlists

function aeMorphLists pList1, pList2, pDuration, pCurrentTime, pEffect, pRound, pMin, pMax
   local tResultList, tCounter, tVal
   if the number of lines of pList1 <> the number of lines of pList2 then return "error: number of lines in lists is not equal"
   repeat for each line theLine in pList1
      add 1 to tCounter
      if line tCounter of pList1 is empty or line tCounter of pList2 is empty then
         put cr after tResultList
         next repeat
      end if
      if the number of items of line tCounter of pList1 <> the number of items of line tCounter of pList2 then return "error: number of items in lists is not equal"
      repeat with i = 1 to the number of items of theLine
         switch pEffect
            case "bounce"
               put aeBounceEaseOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime) into tVal
               break
            case "overShoot"
               put aeoverShootEaseOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime) into tVal
               break
            case "in"
               put aeEaseIn(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 3) into tVal
               break
            case "out"
               put aeEaseOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 3) into tVal
               break
            case "inOut"
               put aeEaseInOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 3) into tVal
               break
            default
               put aeEaseIn(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 2) into tVal
               break
         end switch
         if pRound is true then put round(tVal) into tVal
         if pMin is not empty then
            if tVal < pMin then
               put pMin into tVal
            end if
         end if
         if pMax is not empty then
            if tVal > pMax then
               put pMax into tVal
            end if
         end if
         put tVal & "," after tResultList
      end repeat
      put cr into char - 1 of tResultList
   end repeat
   delete char - 1 of tResultList
   return tResultList
end aeMorphLists


function aeMorphGradient pList1, pList2, pDuration, pCurrentTime, pEffect
   --answer pDuration & cr & pCurrenttime
   local tResultList, tCounter, tVal
   if the number of lines of pList1 <> the number of lines of pList2 then return "error: number of lines in lists is not equal"
   repeat for each line theLine in pList1
      add 1 to tCounter
      if line tCounter of pList1 is empty or line tCounter of pList2 is empty then
         put cr after tResultList
         next repeat
      end if
      if the number of items of line tCounter of pList1 <> the number of items of line tCounter of pList2 then return "error: number of items in lists is not equal"
      repeat with i = 1 to the number of items of theLine
         switch pEffect
            case "bounce"
               put aeBounceEaseOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime) into tVal
               break
            case "overShoot"
               put aeoverShootEaseOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime) into tVal
               break
            case "in"
               put aeEaseIn(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 3) into tVal
               break
            case "out"
               put aeEaseOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 3) into tVal
               break
            case "inOut"
               put aeEaseInOut(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 3) into tVal
               break
            default
               put aeEaseIn(item i of line tCounter of pList1, item i of line tCounter of pList2, pDuration, pCurrentTime, 2) into tVal
               break
         end switch
         if i = 1 then
            if tVal > 1 then put 1 into tVal
            if tVal < 0 then put 0 into tVal
         end if
         if i > 1 then
            put round(tVal) into tVal
            if tVal > 255 then put 255 into tVal
            if tVal < 0 then put 0 into tVal
         end if
         put tVal & "," after tResultList
      end repeat
      put cr into char - 1 of tResultList
   end repeat
   delete char - 1 of tResultList
   return tResultList
end aeMorphGradient

--> 2.9 easing stuff

function aeBounceEaseIn pStart, pEnd, pDuration, pCurrentTime
   if pStart is not a number then return "error: start is not a number"
   if pEnd is not a number then return "error: end is not a number"
   if pDuration is not a number then return "error: duration is not a number"
   if pDuration < 0 then return "error: duration is < 0"
   if pCurrentTime is not a number then return "error: currenttime is not a number"
   return pEnd - aeBounceEaseOut(pDuration - pCurrentTime, 0, pEnd, pDuration) + pStart
end aeBounceEaseIn

function aeBounceEaseOut pStart, pEnd, pDuration, pCurrentTime
   local tValue
   if pStart is not a number then return "error: start is not a number"
   if pEnd is not a number then return "error: end is not a number"
   if pDuration is not a number then return "error: duration is not a number"
   if pDuration < 0 then return "error: duration is < 0"
   if pCurrentTime is not a number then return "error: currenttime is not a number"
   put pEnd - pStart into tValue
   if pCurrentTime > pDuration then put pDuration into pCurrentTime
   if pCurrentTime / pDuration < 1 / 2.75 then
      return tValue * (7.56525 * (pCurrentTime / pDuration) ^ 2) + pStart -- & " if 1"
    else
      if pCurrentTime / pDuration < 2 / 2.75 then

         return tValue * (7.5625 * ((pCurrentTime / pDuration) - (1.5 / 2.75)) * ((pCurrentTime / pDuration) - (1.5 / 2.75)) + 0.75) + pStart -- & " if 2"
       else
         if pCurrentTime / pDuration < 2.5 / 2.75 then

            return tValue * (7.5625 * ((pCurrentTime / pDuration) - (2.25 / 2.75)) * ((pCurrentTime / pDuration) - (2.25 / 2.75)) + 0.9375) + pStart -- & " if 3"
          else
            return tValue * (7.5625 * ((pCurrentTime / pDuration) - (2.625 / 2.75)) * ((pCurrentTime / pDuration) - (2.625 / 2.75)) + 0.984375) + pStart --& " if 4"
         end if
      end if
   end if
end aeBounceEaseOut

function aeOvershootEaseIn pStart, pEnd, pDuration, pCurrentTime, pOvershoot
   if pStart is not a number then return "error: start is not a number"
   if pEnd is not a number then return "error: end is not a number"
   if pDuration is not a number then return "error: duration is not a number"
   if pDuration < 0 then return "error: duration is < 0"
   if pOverShoot is not a number then return "error: overshoot is not a number"
   if pOvershoot is empty then put 1.70158 into pOvershoot

   if pCurrentTime is not a number then return "error: currenttime is not a number"
   return (pEnd - pStart) * (pCurrentTime / pDuration) * (pcurrentTime / pDuration) * ((pOvershoot + 1) * (pcurrenttime / pDuration) - pOvershoot) + pStart
end aeOvershootEaseIn

function aeOverShootEaseOut pStart, pEnd, pDuration, pCurrentTime, pOvershoot
   if pOvershoot is empty then put 1.70158 into pOvershoot
   if pStart is not a number then return "error: start is not a number"
   if pEnd is not a number then return "error: end is not a number"
   if pDuration is not a number then return "error: duration is not a number"
   if pDuration < 0 then return "error: duration is < 0"
   if pOverShoot is not a number then return "error: overshoot is not a number"
   if pCurrentTime is not a number then return "error: currenttime is not a number"
   if pOvershoot is empty then put 1.70158 into pOvershoot
   return (pEnd - pStart) * ((pCurrentTime / pDuration - 1) * (pCurrentTime / pDuration - 1) * ((pOverShoot + 1) * (pCurrentTime / pDuration - 1) + pOvershoot) + 1) + pStart
end aeOverShootEaseOut

command aeDebug pValue
   put cr & pValue after msg
end aeDebug

--> 3.0 update

on aeRotateGroup
   local tControl, tX, tY, tDuration, tMethod, tParameters, tDistance, tAngle
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tX
   put item 3 of tParameters into tY
   put item 4 of tParameters into tAngle
   put item 5 of tParameters into tDuration
   put item 6 of tParameters into tMethod

   repeat with i = 1 to the number of controls of tControl
      if the name of control i of tControl begins with "group" then next repeat
      put distance(tx, ty, the loc of control i of tControl) into sAERotateGroup[tControl]["controls"][the long ID of control i of tControl]["Distance"]
      put findPreciseAngleX(tX, tY, the loc of control i of tControl) into sAERotateGroup[tControl]["controls"][the long ID of control i of tControl]["Angle"]
   end repeat
   put tX, tY into sAERotateGroup[tControl]["center"]
   put tMethod into sAERotateGroup[tControl]["Effect"]
   put tDuration into sAERotateGroup[tControl]["Duration"]
   put tAngle into sAERotateGroup[tControl]["Angle"]

   if not sAELockRotateGroup then
      put the milliSecs into sAERotateGroup[tControl]["StartTime"]
      if "aeGeneral" is not in the pendingmessages then
         aeGeneral
      end if
    else
      put "pending" into sAERotateGroup[tControl]["StartTime"]
   end if
end aeRotateGroup

local moof

on aeCrossfade pControl1, pControl2, pDuration
   local tTarget
   if there is no pControl1 then return "aeError: " & pControl1 && "is not a valid control reference"
   if there is no pControl2 then return "aeError: " & pControl2 && "is not a valid control reference"
   if pDuration is not a number then return "aeError: Duration is not a number"
   set the blendlevel of pControl1 to 100
   set the blendlevel of pControl2 to 0
   set the visible of pControl1 to true
   set the visible of pControl2 to true
   replace quote with "§$aeQuote$§" in pControl1
   replace quote with "§$aeQuote$§" in pControl2
   put the long id of the target into tTarget
   replace quote with "§$aeQuote$§" in tTarget
   _aeCrossfade pControl1, pControl2, pDuration, the millisecs, tTarget
   put 0 into moof
end aeCrossfade

on _aeCrossfade pControl1, pControl2, pDuration, pStart, pTarget
   local tControl1, tControl2, tTarget
   put pControl1 into tControl1
   put pControl2 into tControl2
   replace "§$aeQuote$§" with quote in tControl1
   replace "§$aeQuote$§" with quote in tControl2
   local tElapsed, tValue
   put the millisecs - pStart into tElapsed
   put round(aeEaseIn(0, 100, pDuration, tElapsed, 1)) into tValue
   set the blendlevel of tControl1 to 100 - tValue
   set the blendlevel of tControl2 to tValue
   if tElapsed < pDuration then
      send "_aeCrossfade" && pControl1, pControl2, pDuration, pStart, pTarget to me in 25 millisecs
    else
      set the visible of tControl2 to false
      set the blendlevel of tControl2 to 0
      put pTarget into tTarget
      replace "§$aeQuote$§" with quote in tTarget
      dispatch "aeCrossfadeDone" to tTarget
   end if
end _aeCrossfade

on aeFadeIn pControl, pDuration
   local tTarget
   if there is no pControl then return "aeError: " & pControl && "is not a valid control reference"
   if pDuration is not a number then return "aeError: Duration is not a number"
   set the blendlevel of pControl to 100
   set the visible of pControl to true
   replace quote with "§$aeQuote$§" in pControl
   put the long id of the target into tTarget
   replace quote with "§$aeQuote$§" in tTarget
   _aeFadeIn pControl, pDuration, the millisecs, tTarget
end aeFadeIn

on _aeFadeIn pControl, pDuration, pStart, pTarget
   local tControl, tTarget
   put pControl into tControl
   replace "§$aeQuote$§" with quote in tControl
   local tElapsed, tValue
   put the millisecs - pStart into tElapsed
   put round(aeEaseIn(0, 100, pDuration, tElapsed, 1)) into tValue
   set the blendlevel of tControl to 100 - tValue
   if tElapsed < pDuration then
      send "_aeFadeIn" && pControl, pDuration, pStart, pTarget to me in 25 millisecs
    else
      put pTarget into tTarget
      replace "§$aeQuote$§" with quote in tTarget
      dispatch "aeFadeInDone" to tTarget
   end if
end _aeFadeIn

on aeFadeOut pControl, pDuration
   local tTarget
   if there is no pControl then return "aeError: " & pControl && "is not a valid control reference"
   if pDuration is not a number then return "aeError: Duration is not a number"
   set the blendlevel of pControl to 0
   set the visible of pControl to true
   replace quote with "§$aeQuote$§" in pControl
   put the long id of the target into tTarget
   replace quote with "§$aeQuote$§" in tTarget
   _aeFadeOut pControl, pDuration, the millisecs, tTarget
end aeFadeOut

on _aeFadeOut pControl, pDuration, pStart, pTarget
   local tControl, tTarget
   put pControl into tControl
   replace "§$aeQuote$§" with quote in tControl
   local tElapsed, tValue
   put the millisecs - pStart into tElapsed
   put round(aeEaseIn(0, 100, pDuration, tElapsed, 1)) into tValue
   set the blendlevel of tControl to tValue
   if tElapsed < pDuration then
      send "_aeFadeOut" && pControl, pDuration, pStart, pTarget to me in 25 millisecs
    else
      put pTarget into tTarget
      replace "§$aeQuote$§" with quote in tTarget
      dispatch "aeFadeOutDone" to tTarget
      hide tControl
      set the blendlevel of tControl to 0
   end if
end _aeFadeOut


local sAELockRectChanging, tAeChangeRect
local sAELockScrolls, tAeScrolling

on aeChangeRect
   local tControl, tLeft, tRight, tTop, tBottom, tDuration, tMethod, tParameters
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tLeft
   put item 3 of tParameters into tTop
   put item 4 of tParameters into tRight
   put item 5 of tParameters into tBottom
   put item 6 of tParameters into tDuration
   put item 7 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   aeStopChangingWidth tControl
   aeStopChangingHeight tControl
   if word 1 of the long name of tControl is "card" then return "error: can not resize a card"
   if tLeft is not an integer then return "error:" && tLeft & "," & tTop & "," & tRight & ";" & tBottom && "is not a valid rectangle"
   if tTop is not an integer then return "error:" && tLeft & "," & tTop & "," & tRight & ";" & tBottom && "is not a valid rectangle"
   if tRight is not an integer then return "error:" && tLeft & "," & tTop & "," & tRight & ";" & tBottom && "is not a valid rectangle"
   if tBottom is not an integer then return "error:" && tLeft & "," & tTop & "," & tRight & ";" & tBottom && "is not a valid rectangle"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   if not sAELockRectChanging then
      put tLeft, tTop, tRight, tBottom, tDuration, tMethod, item 1 of the rect of tControl, item 2 of the rect of tControl, item 3 of the rect of tControl, item 4 of the rect of tControl, the milliseconds into tAeChangeRect[the long id of tControl]
      if "aeChangingRect" is not in the pendingmessages then
         aeChangingRect
      end if
    else
      put tLeft, tTop, tRight, tBottom, tDuration, tMethod, item 1 of the rect of tControl, item 2 of the rect of tControl, item 3 of the rect of tControl, item 4 of the rect of tControl, "pending" into tAeChangeRect[the long id of tControl]
   end if
end aeChangeRect

on aeLockRects
   put true into sAELockRectChanging
end aeLockRects

on aeUnlockRects
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeRect
      if item 11 of tAeChangeRect[pControl] <> "pending" then next repeat
      put tNow into item 11 of tAeChangeRect[pControl]
   end repeat
   put false into sAELockRectChanging
   if "aeChangingRect" is not in the pendingmessages then aeChangingRect
end aeUnlockRects

local sTimeTakenToChangeRects

command aeChangingRect
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tLeft, tTop, tRight, tBottom, tDuration, tMethod, tEndX, tStartLeft, tDestLeft, tStartTop, tDestTop, tStartRight, tDestRight, tStartBottom, tDestBottom, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeRects into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeRects
   --lock screen
   repeat for each line pControl in the keys of tAeChangeRect
      send "aeEnterFrame" && "aeChangeRect" to pcontrol
      put item 1 of tAeChangeRect[pControl] into tDestLeft
      put item 2 of tAeChangeRect[pControl] into tDestTop
      put item 3 of tAeChangeRect[pControl] into tDestRight
      put item 4 of tAeChangeRect[pControl] into tDestBottom
      put item 5 of tAeChangeRect[pControl] into tDuration
      put item 6 of tAeChangeRect[pControl] into tMethod
      put item 7 of tAeChangeRect[pControl] into tStartLeft
      put item 8 of tAeChangeRect[pControl] into tStartTop
      put item 9 of tAeChangeRect[pControl] into tStartRight
      put item 10 of tAeChangeRect[pControl] into tStartBottom
      put item 11 of tAeChangeRect[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(tStartLeft, tDestLeft, tDuration, the milliseconds - tStartTime, 3) into tLeft
            put aeEaseIn(tStartTop, tDestTop, tDuration, the milliseconds - tStartTime, 3) into tTop
            put aeEaseIn(tStartRight, tDestRight, tDuration, the milliseconds - tStartTime, 3) into tRight
            put aeEaseIn(tStartBottom, tDestBottom, tDuration, the milliseconds - tStartTime, 3) into tBottom
            break
         case "out"
            put aeEaseOut(tStartLeft, tDestLeft, tDuration, the milliseconds - tStartTime, 3) into tLeft
            put aeEaseOut(tStartTop, tDestTop, tDuration, the milliseconds - tStartTime, 3) into tTop
            put aeEaseOut(tStartRight, tDestRight, tDuration, the milliseconds - tStartTime, 3) into tRight
            put aeEaseOut(tStartBottom, tDestBottom, tDuration, the milliseconds - tStartTime, 3) into tBottom
            break
         case "inOut"
            put aeEaseInOut(tStartLeft, tDestLeft, tDuration, the milliseconds - tStartTime, 3) into tLeft
            put aeEaseInOut(tStartTop, tDestTop, tDuration, the milliseconds - tStartTime, 3) into tTop
            put aeEaseInOut(tStartRight, tDestRight, tDuration, the milliseconds - tStartTime, 3) into tRight
            put aeEaseInOut(tStartBottom, tDestBottom, tDuration, the milliseconds - tStartTime, 3) into tBottom
            break
         case "bounce"
            put aeBounceEaseOut(tStartLeft, tDestLeft, tDuration, the milliseconds - tStartTime) into tLeft
            put aeBounceEaseOut(tStartTop, tDestTop, tDuration, the milliseconds - tStartTime) into tTop
            put aeBounceEaseOut(tStartRight, tDestRight, tDuration, the milliseconds - tStartTime) into tRight
            put aeBounceEaseOut(tStartBottom, tDestBottom, tDuration, the milliseconds - tStartTime) into tBottom
            break
         case "overshoot"
            put aeOverShootEaseOut(tStartLeft, tDestLeft, tDuration, the milliseconds - tStartTime) into tLeft
            put aeOverShootEaseOut(tStartTop, tDestTop, tDuration, the milliseconds - tStartTime) into tTop
            put aeOverShootEaseOut(tStartRight, tDestRight, tDuration, the milliseconds - tStartTime) into tRight
            put aeOverShootEaseOut(tStartBottom, tDestBottom, tDuration, the milliseconds - tStartTime) into tBottom
            break
         default
            put aeEaseIn(tStartLeft, tDestLeft, tDuration, the milliseconds - tStartTime, 1) into tLeft
            put aeEaseIn(tStartTop, tDestTop, tDuration, the milliseconds - tStartTime, 1) into tTop
            put aeEaseIn(tStartRight, tDestRight, tDuration, the milliseconds - tStartTime, 1) into tRight
            put aeEaseIn(tStartBottom, tDestBottom, tDuration, the milliseconds - tStartTime, 1) into tBottom
            break
      end switch
      if the milliseconds - tStartTime < tDuration then
         set the rect of pControl to tLeft, tTop, tRight, tBottom
       else
         if tDestLeft, tDestTop, tDestRight, tDestBottom is a rectangle then
            set the rect of pControl to tDestLeft, tDestTop, tDestRight, tDestBottom
         end if
         delete variable tAeChangeRect[pControl]
         dispatch "aeChangeRectDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeRect" to pControl
   end repeat
   --   unlock screen
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeRect is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingRect" is not in the pendingmessages then
            send "aeChangingRect" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingRect" is not in the pendingmessages then
            send "aeChangingRect" to me in 5 millisecs
         end if
      end if
   end if
   --   wait 0 milliseconds with messages
   --put "changingrect" && the millisecs
end aeChangingRect

local sAELockHeightChanging, tAeChangeHeight

on aeChangeHeight
   local tControl, tHeight, tDuration, tMethod, tParameters
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tHeight
   put item 3 of tParameters into tDuration
   put item 4 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if word 1 of the long name of tControl is "card" then return "error: can not resize a card"
   if tHeight is not an integer then return "error:" && tHeight && "is not a valid height"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   aeStopChangingRect tControl

   if not sAELockHeightChanging then
      put tHeight, tDuration, tMethod, the height of tControl, the milliseconds into tAeChangeHeight[the long id of tControl]
      if "aeChangingHeight" is not in the pendingmessages then
         aeChangingHeight
      end if
    else
      put tHeight, tDuration, tMethod, the height of tControl, "pending" into tAeChangeHeight[the long id of tControl]
   end if
end aeChangeHeight

on aeLockHeights
   put true into sAELockHeightChanging
end aeLockHeights

on aeUnlockHeights
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeHeight
      if item 5 of tAeChangeHeight[pControl] <> "pending" then next repeat
      put tNow into item 5 of tAeChangeHeight[pControl]
   end repeat
   put false into sAELockHeightChanging
   if "aeChangingHeight" is not in the pendingmessages then aeChangingHeight
end aeUnlockHeights

local sTimeTakenToChangeHeights

command aeChangingHeight
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tHeight, tDuration, tMethod, tStartHeight, tDestHeight, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeHeights into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeHeights
   --lock screen
   repeat for each line pControl in the keys of tAeChangeHeight
      send "aeEnterFrame" && "aeChangeHeight" to pcontrol
      put item 1 of tAeChangeHeight[pControl] into tDestHeight
      put item 2 of tAeChangeHeight[pControl] into tDuration
      put item 3 of tAeChangeHeight[pControl] into tMethod
      put item 4 of tAeChangeHeight[pControl] into tStartHeight
      put item 5 of tAeChangeHeight[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(tStartHeight, tDestHeight, tDuration, the milliseconds - tStartTime, 3) into tHeight
            break
         case "out"
            put aeEaseOut(tStartHeight, tDestHeight, tDuration, the milliseconds - tStartTime, 3) into tHeight
            break
         case "inOut"
            put aeEaseInOut(tStartHeight, tDestHeight, tDuration, the milliseconds - tStartTime, 3) into tHeight
            break
         case "bounce"
            put aeBounceEaseOut(tStartHeight, tDestHeight, tDuration, the milliseconds - tStartTime) into tHeight
            break
         case "overshoot"
            put aeOverShootEaseOut(tStartHeight, tDestHeight, tDuration, the milliseconds - tStartTime) into tHeight
            break
         default
            put aeEaseIn(tStartHeight, tDestHeight, tDuration, the milliseconds - tStartTime, 1) into tHeight
            break
      end switch
      if the milliseconds - tStartTime < tDuration then
         set the height of pControl to tHeight
       else
         if tHeight is a number then
            set the height of pControl to tHeight
         end if
         delete variable tAeChangeHeight[pControl]
         dispatch "aeChangeHeightDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeHeight" to pControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeHeight is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingHeight" is not in the pendingmessages then
            send "aeChangingHeight" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingHeight" is not in the pendingmessages then
            send "aeChangingHeight" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingHeight

local sAELockWidthChanging, tAeChangeWidth

on aeChangeWidth
   local tControl, tWidth, tDuration, tMethod, tParameters
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tWidth
   put item 3 of tParameters into tDuration
   put item 4 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if word 1 of the long name of tControl is "card" then return "error: can not resize a card"
   if tWidth is not an integer then return "error:" && tWidth && "is not a valid Width"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   aeStopChangingRect tControl

   if not sAELockWidthChanging then
      put tWidth, tDuration, tMethod, the width of tControl, the milliseconds into tAeChangeWidth[the long id of tControl]
      if "aeChangingWidth" is not in the pendingmessages then
         aeChangingWidth
      end if
    else
      put tWidth, tDuration, tMethod, the width of tControl, "pending" into tAeChangeWidth[the long id of tControl]
   end if
end aeChangeWidth

on aeLockWidths
   put true into sAELockWidthChanging
end aeLockWidths

on aeUnlockWidths
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeWidth
      if item 5 of tAeChangeWidth[pControl] <> "pending" then next repeat
      put tNow into item 5 of tAeChangeWidth[pControl]
   end repeat
   put false into sAELockWidthChanging
   if "aeChangingWidth" is not in the pendingmessages then aeChangingWidth
end aeUnlockWidths

local sTimeTakenToChangeWidths

command aeChangingWidth
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tWidth, tDuration, tMethod, tStartWidth, tDestWidth, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeWidths into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeWidths
   --lock screen
   repeat for each line pControl in the keys of tAeChangeWidth
      send "aeEnterFrame" && "aeChangeWidth" to pcontrol
      put item 1 of tAeChangeWidth[pControl] into tDestWidth
      put item 2 of tAeChangeWidth[pControl] into tDuration
      put item 3 of tAeChangeWidth[pControl] into tMethod
      put item 4 of tAeChangeWidth[pControl] into tStartWidth
      put item 5 of tAeChangeWidth[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(tStartWidth, tDestWidth, tDuration, the milliseconds - tStartTime, 3) into tWidth
            break
         case "out"
            put aeEaseOut(tStartWidth, tDestWidth, tDuration, the milliseconds - tStartTime, 3) into tWidth
            break
         case "inOut"
            put aeEaseInOut(tStartWidth, tDestWidth, tDuration, the milliseconds - tStartTime, 3) into tWidth
            break
         case "bounce"
            put aeBounceEaseOut(tStartWidth, tDestWidth, tDuration, the milliseconds - tStartTime) into tWidth
            break
         case "overshoot"
            put aeOverShootEaseOut(tStartWidth, tDestWidth, tDuration, the milliseconds - tStartTime) into tWidth
            break
         default
            put aeEaseIn(tStartWidth, tDestWidth, tDuration, the milliseconds - tStartTime, 1) into tWidth
            break
      end switch
      if the milliseconds - tStartTime < tDuration then
         set the width of pControl to tWidth
       else
         if tWidth is a number then
            set the width of pControl to tWidth
         end if
         delete variable tAeChangeWidth[pControl]
         dispatch "aeChangeWidthDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeWidth" to pControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeWidth is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingWidth" is not in the pendingmessages then
            send "aeChangingWidth" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingWidth" is not in the pendingmessages then
            send "aeChangingWidth" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingWidth

local sAELockHScrollChanging, tAeChangeHScroll

on aeChangeHScroll
   local tControl, tHScroll, tDuration, tMethod, tParameters, tType
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tHScroll
   put item 3 of tParameters into tDuration
   put item 4 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   put word 1 of the long name of tControl into tType
   if word 1 of the long name of tControl is not among the items of "group,field" then return "error: can not scroll a" && tType
   if tHScroll is not an integer then return "error:" && tHScroll && "is not a valid HScroll"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   if not sAELockHScrollChanging then
      put tHScroll, tDuration, tMethod, the hscroll of tControl, the milliseconds into tAeChangeHScroll[the long id of tControl]
      if "aeChangingHScroll" is not in the pendingmessages then
         aeChangingHScroll
      end if
    else
      put tHScroll, tDuration, tMethod, the hscroll of tControl, "pending" into tAeChangeHScroll[the long id of tControl]
   end if
end aeChangeHScroll

on aeLockHScrolls
   put true into sAELockHScrollChanging
end aeLockHScrolls

on aeUnlockHScrolls
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeHScroll
      if item 5 of tAeChangeHScroll[pControl] <> "pending" then next repeat
      put tNow into item 5 of tAeChangeHScroll[pControl]
   end repeat
   put false into sAELockHScrollChanging
   if "aeChangingHScroll" is not in the pendingmessages then aeChangingHScroll
end aeUnlockHScrolls

local sTimeTakenToChangeHScrolls

command aeChangingHScroll
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tHScroll, tDuration, tMethod, tStartHScroll, tDestHScroll, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeHScrolls into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeHScrolls
   --lock screen
   repeat for each line pControl in the keys of tAeChangeHScroll
      send "aeEnterFrame" && "aeChangeHScroll" to pcontrol
      put item 1 of tAeChangeHScroll[pControl] into tDestHScroll
      put item 2 of tAeChangeHScroll[pControl] into tDuration
      put item 3 of tAeChangeHScroll[pControl] into tMethod
      put item 4 of tAeChangeHScroll[pControl] into tStartHScroll
      put item 5 of tAeChangeHScroll[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(tStartHScroll, tDestHScroll, tDuration, the milliseconds - tStartTime, 3) into tHScroll
            break
         case "out"
            put aeEaseOut(tStartHScroll, tDestHScroll, tDuration, the milliseconds - tStartTime, 3) into tHScroll
            break
         case "inOut"
            put aeEaseInOut(tStartHScroll, tDestHScroll, tDuration, the milliseconds - tStartTime, 3) into tHScroll
            break
         case "bounce"
            put aeBounceEaseOut(tStartHScroll, tDestHScroll, tDuration, the milliseconds - tStartTime) into tHScroll
            break
         case "overshoot"
            put aeOverShootEaseOut(tStartHScroll, tDestHScroll, tDuration, the milliseconds - tStartTime) into tHScroll
            break
         default
            put aeEaseIn(tStartHScroll, tDestHScroll, tDuration, the milliseconds - tStartTime, 1) into tHScroll
            break
      end switch
      put round(tHScroll) into tHScroll
      if the milliseconds - tStartTime < tDuration then
         set the hscroll of pControl to tHScroll
       else
         if tHScroll is a number then
            set the hscroll of pControl to tHScroll
         end if
         delete variable tAeChangeHScroll[pControl]
         dispatch "aeChangeHScrollDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeHScroll" to pControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeHScroll is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingHScroll" is not in the pendingmessages then
            send "aeChangingHScroll" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingHScroll" is not in the pendingmessages then
            send "aeChangingHScroll" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingHScroll

local sAELockVScrollChanging, tAeChangeVScroll

on aeChangeVScroll
   local tControl, tVScroll, tDuration, tMethod, tParameters
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tVScroll
   put item 3 of tParameters into tDuration
   put item 4 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if word 1 of the long name of tControl is "card" then return "error: can not resize a card"
   if tVScroll is not an integer then return "error:" && tVScroll && "is not a valid VScroll"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   if not sAELockVScrollChanging then
      put tVScroll, tDuration, tMethod, the vscroll of tControl, the milliseconds into tAeChangeVScroll[the long id of tControl]
      if "aeChangingVScroll" is not in the pendingmessages then
         aeChangingVScroll
      end if
    else
      put tVScroll, tDuration, tMethod, the vscroll of tControl, "pending" into tAeChangeVScroll[the long id of tControl]
   end if
end aeChangeVScroll

on aeLockVScrolls
   put true into sAELockVScrollChanging
end aeLockVScrolls

on aeUnlockVScrolls
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeVScroll
      if item 5 of tAeChangeVScroll[pControl] <> "pending" then next repeat
      put tNow into item 5 of tAeChangeVScroll[pControl]
   end repeat
   put false into sAELockVScrollChanging
   if "aeChangingVScroll" is not in the pendingmessages then aeChangingVScroll
end aeUnlockVScrolls

local sTimeTakenToChangeVScrolls

command aeChangingVScroll
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tVScroll, tDuration, tMethod, tStartVScroll, tDestVScroll, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeVScrolls into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeVScrolls
   --lock screen
   repeat for each line pControl in the keys of tAeChangeVScroll
      send "aeEnterFrame" && "aeChangeVScroll" to pcontrol
      put item 1 of tAeChangeVScroll[pControl] into tDestVScroll
      put item 2 of tAeChangeVScroll[pControl] into tDuration
      put item 3 of tAeChangeVScroll[pControl] into tMethod
      put item 4 of tAeChangeVScroll[pControl] into tStartVScroll
      put item 5 of tAeChangeVScroll[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(tStartVScroll, tDestVScroll, tDuration, the milliseconds - tStartTime, 3) into tVScroll
            break
         case "out"
            put aeEaseOut(tStartVScroll, tDestVScroll, tDuration, the milliseconds - tStartTime, 3) into tVScroll
            break
         case "inOut"
            put aeEaseInOut(tStartVScroll, tDestVScroll, tDuration, the milliseconds - tStartTime, 3) into tVScroll
            break
         case "bounce"
            put aeBounceEaseOut(tStartVScroll, tDestVScroll, tDuration, the milliseconds - tStartTime) into tVScroll
            break
         case "overshoot"
            put aeOverShootEaseOut(tStartVScroll, tDestVScroll, tDuration, the milliseconds - tStartTime) into tVScroll
            break
         default
            put aeEaseIn(tStartVScroll, tDestVScroll, tDuration, the milliseconds - tStartTime, 1) into tVScroll
            break
      end switch
      put round(tVscroll) into tVscroll
      if the milliseconds - tStartTime < tDuration then
         set the vscroll of pControl to tVScroll
       else
         if tVScroll is a number then
            set the vscroll of pControl to tVScroll
         end if
         delete variable tAeChangeVScroll[pControl]
         dispatch "aeChangeVScrollDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeVScroll" to pControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeVScroll is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingVScroll" is not in the pendingmessages then
            send "aeChangingVScroll" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingVScroll" is not in the pendingmessages then
            send "aeChangingVScroll" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingVScroll

local sAELockBackColorChanging, tAeChangeBackColor

on aeChangeBackColor
   local tControl, tBackColor, tDuration, tMethod, tParameters, tCurrentBackColor
   if sAEFrameRate is empty then aeResetFrameRate
   /*
   -- Gott sei Dank bin ich den Scheiss mit der 5er Engine los geworden. Ein Grund mehr engine 4.x nicht mehr zu unterstützen.
   if "animationEngine" is not among the lines of the openstacks then
      -- Mein liebes zukünftiges Ich, bitte vergib mir!!!
      local tDefault
      put the defaultstack into tDefault
      open inv "animationEngine"
      set the defaultstack to tDefault
   end if
   */
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   if item 2 of tParameters is a color and item 2 of tParameters is not a number then
      -- we got no RGB values here
      set the backcolor of grc "testColor" of me to item 2 of tParameters

      set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me

      put the backcolor of grc "testColor" of me into tBackColor

      put item 3 of tParameters into tDuration
      put item 4 of tParameters into tMethod
    else
      put item 2 to 4 of tParameters into tBackColor
      put item 5 of tParameters into tDuration
      put item 6 of tParameters into tMethod
   end if
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if tBackColor is not a color then return "error:" && tBackColor && "is not a valid color"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   set the backcolor of grc "testColor" of me to the effective backcolor of tControl
   set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me
   put the backcolor of grc "testColor" of me into tCurrentBackColor
   if not sAELockBackColorChanging then
      put tBackColor, tDuration, tMethod, tCurrentBackColor, the milliseconds into tAeChangeBackColor[the long id of tControl]
      if "aeChangingBackColor" is not in the pendingmessages then
         aeChangingBackColor
      end if
    else
      put tBackColor, tDuration, tMethod, tCurrentBackColor, "pending" into tAeChangeBackColor[the long id of tControl]
   end if
end aeChangeBackColor

on aeLockBackColors
   put true into sAELockBackColorChanging
end aeLockBackColors

on aeUnlockBackColors
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeBackColor
      if item 9 of tAeChangeBackColor[pControl] <> "pending" then
         next repeat
      end if
      put tNow into item 9 of tAeChangeBackColor[pControl]
   end repeat
   put false into sAELockBackColorChanging
   if "aeChangingBackColor" is not in the pendingmessages then aeChangingBackColor
end aeUnlockBackColors

local sTimeTakenToChangeBackColors

command aeChangingBackColor

   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tBackColor, tDuration, tMethod, tStartBackColor, tDestBackColor, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeBackColors into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeBackColors
   --lock screen
   repeat for each line pControl in the keys of tAeChangeBackColor
      send "aeEnterFrame" && "aeChangeBackColor" to pcontrol
      put item 1 to 3 of tAeChangeBackColor[pControl] into tDestBackColor
      put item 4 of tAeChangeBackColor[pControl] into tDuration
      put item 5 of tAeChangeBackColor[pControl] into tMethod
      put item 6 to 8 of tAeChangeBackColor[pControl] into tStartBackColor
      put item 9 of tAeChangeBackColor[pControl] into tStartTime
      --      answer  tAeChangeBackColor[pControl]
      --      exit to top
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(item 1 of tStartBackColor, item 1 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 1 of tBackColor
            put aeEaseIn(item 2 of tStartBackColor, item 2 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 2 of tBackColor
            put aeEaseIn(item 3 of tStartBackColor, item 3 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 3 of tBackColor
            break
         case "out"
            put aeEaseOut(item 1 of tStartBackColor, item 1 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 1 of tBackColor
            put aeEaseOut(item 2 of tStartBackColor, item 2 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 2 of tBackColor
            put aeEaseOut(item 3 of tStartBackColor, item 3 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 3 of tBackColor
            break
         case "inOut"
            put aeEaseInOut(item 1 of tStartBackColor, item 1 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 1 of tBackColor
            put aeEaseInOut(item 2 of tStartBackColor, item 2 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 2 of tBackColor
            put aeEaseInOut(item 3 of tStartBackColor, item 3 of tDestBackColor, tDuration, the milliseconds - tStartTime, 3) into item 3 of tBackColor
            break
         case "bounce"
            put aeBounceEaseOut(item 1 of tStartBackColor, item 1 of tDestBackColor, tDuration, the milliseconds - tStartTime) into item 1 of tBackColor
            put aeBounceEaseOut(item 2 of tStartBackColor, item 2 of tDestBackColor, tDuration, the milliseconds - tStartTime) into item 2 of tBackColor
            put aeBounceEaseOut(item 3 of tStartBackColor, item 3 of tDestBackColor, tDuration, the milliseconds - tStartTime) into item 3 of tBackColor
            break
         case "overshoot"
            put aeOverShootEaseOut(item 1 of tStartBackColor, item 1 of tDestBackColor, tDuration, the milliseconds - tStartTime) into item 1 of tBackColor
            put aeOverShootEaseOut(item 2 of tStartBackColor, item 2 of tDestBackColor, tDuration, the milliseconds - tStartTime) into item 2 of tBackColor
            put aeOverShootEaseOut(item 3 of tStartBackColor, item 3 of tDestBackColor, tDuration, the milliseconds - tStartTime) into item 3 of tBackColor
            break
         default
            put aeEaseIn(item 1 of tStartBackColor, item 1 of tDestBackColor, tDuration, the milliseconds - tStartTime, 1) into item 1 of tBackColor
            put aeEaseIn(item 2 of tStartBackColor, item 2 of tDestBackColor, tDuration, the milliseconds - tStartTime, 1) into item 2 of tBackColor
            put aeEaseIn(item 3 of tStartBackColor, item 3 of tDestBackColor, tDuration, the milliseconds - tStartTime, 1) into item 3 of tBackColor
            break
      end switch
      repeat with i = 1 to 3
         put round(item i of tBackColor) into item i of tBackColor
         if item i of tBackColor > 255 then put 255 into item i of tBackColor
         if item i of tBackColor < 0 then put 0 into item i of tBackColor
      end repeat
      if the milliseconds - tStartTime < tDuration then
         set the backcolor of pControl to tBackColor
       else
         if tBackColor is a color then
            set the backcolor of pControl to tBackColor
         end if
         delete variable tAeChangeBackColor[pControl]
         dispatch "aeChangeBackColorDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeBackColor" to pControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeBackColor is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingBackColor" is not in the pendingmessages then
            send "aeChangingBackColor" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingBackColor" is not in the pendingmessages then
            send "aeChangingBackColor" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingBackColor

local sAELockforeColorChanging, tAeChangeforeColor

on aeChangeforeColor
   local tControl, tforeColor, tDuration, tMethod, tParameters, tCurrentforeColor
   if sAEFrameRate is empty then aeResetFrameRate
   --   if "animationEngine" is not among the lines of the openstacks then
   --      local tDefault
   --      put the defaultstack into tDefault
   --      open inv "animationEngine"
   --      set the defaultstack to tDefault
   --  -- WAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHH... Warum nur. Warum....
   --   end if
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   if item 2 of tParameters is a color and item 2 of tParameters is not a number then
      -- we got no RGB values here
      set the backcolor of grc "testColor" of me to item 2 of tParameters
      set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me
      put the backcolor of grc "testColor" of me into tforeColor
      put item 3 of tParameters into tDuration
      put item 4 of tParameters into tMethod
    else
      put item 2 to 4 of tParameters into tforeColor
      put item 5 of tParameters into tDuration
      put item 6 of tParameters into tMethod
   end if
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if tforeColor is not a color then return "error:" && tforeColor && "is not a valid color"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   set the backcolor of grc "testColor" of me to the effective forecolor of tControl
   set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me
   put the backcolor of grc "testColor" of me into tCurrentforeColor
   if not sAELockforeColorChanging then
      put tforeColor, tDuration, tMethod, tCurrentforeColor, the milliseconds into tAeChangeforeColor[the long id of tControl]
      if "aeChangingforeColor" is not in the pendingmessages then
         aeChangingforeColor
      end if
    else
      put tforeColor, tDuration, tMethod, tCurrentforeColor, "pending" into tAeChangeforeColor[the long id of tControl]
   end if
end aeChangeforeColor

on aeLockforeColors
   put true into sAELockforeColorChanging
end aeLockforeColors

on aeUnlockforeColors
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeforeColor
      if item 5 of tAeChangeforeColor[pControl] <> "pending" then next repeat
      put tNow into item 5 of tAeChangeforeColor[pControl]
   end repeat
   put false into sAELockforeColorChanging
   if "aeChangingforeColor" is not in the pendingmessages then aeChangingforeColor
end aeUnlockforeColors

local sTimeTakenToChangeforeColors

command aeChangingforeColor

   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tforeColor, tDuration, tMethod, tStartforeColor, tDestforeColor, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeforeColors into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeforeColors
   --lock screen
   repeat for each line pControl in the keys of tAeChangeforeColor
      send "aeEnterFrame" && "aeChangeForeColor" to pcontrol
      put item 1 to 3 of tAeChangeforeColor[pControl] into tDestforeColor
      put item 4 of tAeChangeforeColor[pControl] into tDuration
      put item 5 of tAeChangeforeColor[pControl] into tMethod
      put item 6 to 8 of tAeChangeforeColor[pControl] into tStartforeColor
      put item 9 of tAeChangeforeColor[pControl] into tStartTime
      --      answer  tAeChangeforeColor[pControl]
      --      exit to top
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(item 1 of tStartforeColor, item 1 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 1 of tforeColor
            put aeEaseIn(item 2 of tStartforeColor, item 2 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 2 of tforeColor
            put aeEaseIn(item 3 of tStartforeColor, item 3 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 3 of tforeColor
            break
         case "out"
            put aeEaseOut(item 1 of tStartforeColor, item 1 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 1 of tforeColor
            put aeEaseOut(item 2 of tStartforeColor, item 2 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 2 of tforeColor
            put aeEaseOut(item 3 of tStartforeColor, item 3 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 3 of tforeColor
            break
         case "inOut"
            put aeEaseInOut(item 1 of tStartforeColor, item 1 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 1 of tforeColor
            put aeEaseInOut(item 2 of tStartforeColor, item 2 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 2 of tforeColor
            put aeEaseInOut(item 3 of tStartforeColor, item 3 of tDestforeColor, tDuration, the milliseconds - tStartTime, 3) into item 3 of tforeColor
            break
         case "bounce"
            put aeBounceEaseOut(item 1 of tStartforeColor, item 1 of tDestforeColor, tDuration, the milliseconds - tStartTime) into item 1 of tforeColor
            put aeBounceEaseOut(item 2 of tStartforeColor, item 2 of tDestforeColor, tDuration, the milliseconds - tStartTime) into item 2 of tforeColor
            put aeBounceEaseOut(item 3 of tStartforeColor, item 3 of tDestforeColor, tDuration, the milliseconds - tStartTime) into item 3 of tforeColor
            break
         case "overshoot"
            put aeOverShootEaseOut(item 1 of tStartforeColor, item 1 of tDestforeColor, tDuration, the milliseconds - tStartTime) into item 1 of tforeColor
            put aeOverShootEaseOut(item 2 of tStartforeColor, item 2 of tDestforeColor, tDuration, the milliseconds - tStartTime) into item 2 of tforeColor
            put aeOverShootEaseOut(item 3 of tStartforeColor, item 3 of tDestforeColor, tDuration, the milliseconds - tStartTime) into item 3 of tforeColor
            break
         default
            put aeEaseIn(item 1 of tStartforeColor, item 1 of tDestforeColor, tDuration, the milliseconds - tStartTime, 1) into item 1 of tforeColor
            put aeEaseIn(item 2 of tStartforeColor, item 2 of tDestforeColor, tDuration, the milliseconds - tStartTime, 1) into item 2 of tforeColor
            put aeEaseIn(item 3 of tStartforeColor, item 3 of tDestforeColor, tDuration, the milliseconds - tStartTime, 1) into item 3 of tforeColor
            break
      end switch
      repeat with i = 1 to 3
         put round(item i of tforeColor) into item i of tforeColor
         if item i of tforeColor > 255 then put 255 into item i of tforeColor
         if item i of tforeColor < 0 then put 0 into item i of tforeColor
      end repeat
      if the milliseconds - tStartTime < tDuration then
         set the forecolor of pControl to tforeColor
       else
         if tforeColor is a color then
            set the forecolor of pControl to tforeColor
         end if
         delete variable tAeChangeforeColor[pControl]
         dispatch "aeChangeforeColorDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeForeColor" to pControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeforeColor is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingforeColor" is not in the pendingmessages then
            send "aeChangingforeColor" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingforeColor" is not in the pendingmessages then
            send "aeChangingforeColor" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingforeColor

local sAELockThumbPositionChanging, tAeChangeThumbPosition

on aeChangeThumbPosition
   local tControl, tThumbPosition, tDuration, tMethod, tParameters, tType
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tThumbPosition
   put item 3 of tParameters into tDuration
   put item 4 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "does not exist"
   put word 1 of the long name of tControl into tType
   if word 1 of the long name of tControl is not among the items of "scrollbar" then return "error: can not set the thumbPosition of a" && tType
   if tThumbPosition is not an integer then return "error:" && tThumbPosition && "is not a valid ThumbPosition"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   if not sAELockThumbPositionChanging then
      put tThumbPosition, tDuration, tMethod, the thumbposition of tControl, the milliseconds into tAeChangeThumbPosition[the long id of tControl]
      if "aeChangingThumbPosition" is not in the pendingmessages then
         aeChangingThumbPosition
      end if
    else
      put tThumbPosition, tDuration, tMethod, the thumbposition of tControl, "pending" into tAeChangeThumbPosition[the long id of tControl]
   end if
end aeChangeThumbPosition

on aeLockThumbPositions
   put true into sAELockThumbPositionChanging
end aeLockThumbPositions

on aeUnlockThumbPositions
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeThumbPosition
      if item 5 of tAeChangeThumbPosition[pControl] <> "pending" then next repeat
      put tNow into item 5 of tAeChangeThumbPosition[pControl]
   end repeat
   put false into sAELockThumbPositionChanging
   if "aeChangingThumbPosition" is not in the pendingmessages then aeChangingThumbPosition
end aeUnlockThumbPositions

local sTimeTakenToChangeThumbPositions

command aeChangingThumbPosition
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tThumbPosition, tDuration, tMethod, tStartThumbPosition, tDestThumbPosition, tStartTime
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeThumbPositions into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeThumbPositions
   --lock screen
   repeat for each line pControl in the keys of tAeChangeThumbPosition
      send "aeEnterFrame" && "aeChangeThumbPosition" to pcontrol
      put item 1 of tAeChangeThumbPosition[pControl] into tDestThumbPosition
      put item 2 of tAeChangeThumbPosition[pControl] into tDuration
      put item 3 of tAeChangeThumbPosition[pControl] into tMethod
      put item 4 of tAeChangeThumbPosition[pControl] into tStartThumbPosition
      put item 5 of tAeChangeThumbPosition[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(tStartThumbPosition, tDestThumbPosition, tDuration, the milliseconds - tStartTime, 3) into tThumbPosition
            break
         case "out"
            put aeEaseOut(tStartThumbPosition, tDestThumbPosition, tDuration, the milliseconds - tStartTime, 3) into tThumbPosition
            break
         case "inOut"
            put aeEaseInOut(tStartThumbPosition, tDestThumbPosition, tDuration, the milliseconds - tStartTime, 3) into tThumbPosition
            break
         case "bounce"
            put aeBounceEaseOut(tStartThumbPosition, tDestThumbPosition, tDuration, the milliseconds - tStartTime) into tThumbPosition
            break
         case "overshoot"
            put aeOverShootEaseOut(tStartThumbPosition, tDestThumbPosition, tDuration, the milliseconds - tStartTime) into tThumbPosition
            break
         default
            put aeEaseIn(tStartThumbPosition, tDestThumbPosition, tDuration, the milliseconds - tStartTime, 1) into tThumbPosition
            break
      end switch
      put round(tThumbPosition) into tThumbPosition
      if the milliseconds - tStartTime < tDuration then
         set the thumbposition of pControl to tThumbPosition
       else
         if tThumbPosition is a number then
            set the thumbposition of pControl to tThumbPosition
         end if
         delete variable tAeChangeThumbPosition[pControl]
         dispatch "aeChangeThumbPositionDone" to pControl
      end if
      send "aeExitFrame" && "aeChangeThumbPosition" to pControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeThumbPosition is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingThumbPosition" is not in the pendingmessages then
            send "aeChangingThumbPosition" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingThumbPosition" is not in the pendingmessages then
            send "aeChangingThumbPosition" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingThumbPosition


--------

local sAELockBackColorOfChunkChanging, tAeChangeBackColorOfChunk

on aeChangeBackColorOfChunk
   local tControl, tBackColorOfChunk, tDuration, tMethod, tParameters, tCurrentBackColorOfChunk, tChunk

   if sAEFrameRate is empty then aeResetFrameRate
   --   if "animationEngine" is not among the lines of the openstacks then
   -- -- Und noch mal... Shit.
   --      local tDefault
   --      put the defaultstack into tDefault
   --      open inv "animationEngine"
   --      set the defaultstack to tDefault
   --   end if
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat

   put item 1 of tParameters into tControl
   put item 2 of tParameters into tChunk
   local tTest, tTest2
   put tChunk && "of" && tControl into tTest
   try
      get tTest
   catch theErr
      return "aeError: Could not evaluate " && tchunk && "of" && tControl
   end try
   put tTest into tTest2
   if word 1 of tTest2 = "char" then
      repeat with i = 1 to the number of words of tTest2
         if word i of tTest2 = "of" then exit repeat
      end repeat
      put "char 1 of" into word 1 to i of tTest2
    else
      put "char 1 of" && tTest into tTest2
   end if
   if item 3 of tParameters is a color and item 2 of tParameters is not a number then
      -- we got no RGB values here
      set the backcolor of grc "testColor" of me to item 3 of tParameters

      set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me

      put the backcolor of grc "testColor" of me into tBackColorOfChunk

      put item 4 of tParameters into tDuration
      put item 5 of tParameters into tMethod
    else
      put item 3 to 5 of tParameters into tBackColorOfChunk
      put item 6 of tParameters into tDuration
      put item 7 of tParameters into tMethod
   end if
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if tBackColorOfChunk is not a color then return "error:" && tBackColorOfChunk && "is not a valid color"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   set the backcolor of grc "testColor" of me to the effective backcolor of tTest2
   set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me
   put the backcolor of grc "testColor" of me into tCurrentBackColorOfChunk
   local tKey
   put (tControl & "," & tChunk) into tKey
   if not sAELockBackColorOfChunkChanging then
      put tBackColorOfChunk, tChunk, tDuration, tMethod, tCurrentBackColorOfChunk, the milliseconds into tAeChangeBackColorOfChunk[tKey]
      if "aeChangingBackColorOfChunk" is not in the pendingmessages then
         aeChangingBackColorOfChunk
      end if
    else
      put tBackColorOfChunk, tChunk, tDuration, tMethod, tCurrentBackColorOfChunk, "pending" into tAeChangeBackColorOfChunk[tKey]
   end if

end aeChangeBackColorOfChunk

on aeLockBackColorOfChunks
   put true into sAELockBackColorOfChunkChanging
end aeLockBackColorOfChunks

on aeUnlockBackColorOfChunks
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeBackColorOfChunk
      if item 6 of tAeChangeBackColorOfChunk[pControl] <> "pending" then next repeat
      put tNow into item 6 of tAeChangeBackColorOfChunk[pControl]
   end repeat
   put false into sAELockBackColorOfChunkChanging
   if "aeChangingBackColorOfChunk" is not in the pendingmessages then aeChangingBackColorOfChunk
end aeUnlockBackColorOfChunks

local sTimeTakenToChangeBackColorOfChunks

command aeChangingBackColorOfChunk
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tBackColorOfChunk, tDuration, tMethod, tStartBackColorOfChunk, tDestBackColorOfChunk, tStartTime, tChunk
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeBackColorOfChunks into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeBackColorOfChunks
   local theControl
   repeat for each line pControl in the keys of tAeChangeBackColorOfChunk
      put item 1 of pControl into theControl
      send "aeEnterFrame" && "aeChangeBackColorOfChunk" to theControl
      put item 1 to 3 of tAeChangeBackColorOfChunk[pControl] into tDestBackColorOfChunk
      put item 4 of tAeChangeBackColorOfChunk[pControl] into tChunk
      put item 5 of tAeChangeBackColorOfChunk[pControl] into tDuration
      put item 6 of tAeChangeBackColorOfChunk[pControl] into tMethod
      put item 7 to 9 of tAeChangeBackColorOfChunk[pControl] into tStartBackColorOfChunk
      put item 10 of tAeChangeBackColorOfChunk[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(item 1 of tStartBackColorOfChunk, item 1 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 1 of tBackColorOfChunk
            put aeEaseIn(item 2 of tStartBackColorOfChunk, item 2 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 2 of tBackColorOfChunk
            put aeEaseIn(item 3 of tStartBackColorOfChunk, item 3 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 3 of tBackColorOfChunk
            break
         case "out"
            put aeEaseOut(item 1 of tStartBackColorOfChunk, item 1 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 1 of tBackColorOfChunk
            put aeEaseOut(item 2 of tStartBackColorOfChunk, item 2 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 2 of tBackColorOfChunk
            put aeEaseOut(item 3 of tStartBackColorOfChunk, item 3 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 3 of tBackColorOfChunk
            break
         case "inOut"
            put aeEaseInOut(item 1 of tStartBackColorOfChunk, item 1 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 1 of tBackColorOfChunk
            put aeEaseInOut(item 2 of tStartBackColorOfChunk, item 2 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 2 of tBackColorOfChunk
            put aeEaseInOut(item 3 of tStartBackColorOfChunk, item 3 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 3 of tBackColorOfChunk
            break
         case "bounce"
            put aeBounceEaseOut(item 1 of tStartBackColorOfChunk, item 1 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime) into item 1 of tBackColorOfChunk
            put aeBounceEaseOut(item 2 of tStartBackColorOfChunk, item 2 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime) into item 2 of tBackColorOfChunk
            put aeBounceEaseOut(item 3 of tStartBackColorOfChunk, item 3 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime) into item 3 of tBackColorOfChunk
            break
         case "overshoot"
            put aeOverShootEaseOut(item 1 of tStartBackColorOfChunk, item 1 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime) into item 1 of tBackColorOfChunk
            put aeOverShootEaseOut(item 2 of tStartBackColorOfChunk, item 2 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime) into item 2 of tBackColorOfChunk
            put aeOverShootEaseOut(item 3 of tStartBackColorOfChunk, item 3 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime) into item 3 of tBackColorOfChunk
            break
         default
            put aeEaseIn(item 1 of tStartBackColorOfChunk, item 1 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 1) into item 1 of tBackColorOfChunk
            put aeEaseIn(item 2 of tStartBackColorOfChunk, item 2 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 1) into item 2 of tBackColorOfChunk
            put aeEaseIn(item 3 of tStartBackColorOfChunk, item 3 of tDestBackColorOfChunk, tDuration, the milliseconds - tStartTime, 1) into item 3 of tBackColorOfChunk
            break
      end switch
      repeat with i = 1 to 3
         put round(item i of tBackColorOfChunk) into item i of tBackColorOfChunk
         if item i of tBackColorOfChunk > 255 then put 255 into item i of tBackColorOfChunk
         if item i of tBackColorOfChunk < 0 then put 0 into item i of tBackColorOfChunk
      end repeat
      local assembleChunk
      put tChunk & " of " & item 1 of pControl into assembleChunk
      if the milliseconds - tStartTime < tDuration then
         do "set the BackColor of" && assembleChunk && "to" && tBackColorOfChunk
       else
         if tBackColorOfChunk is a color then
            do "set the BackColor of" && assembleChunk && "to" && tBackColorOfChunk
         end if
         delete variable tAeChangeBackColorOfChunk[pControl]
         dispatch "aeChangeBackColorOfChunkDone" to theControl
      end if
      send "aeExitFrame" && "aeChangeBackColorOfChunk" to theControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeBackColorOfChunk is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingBackColorOfChunk" is not in the pendingmessages then
            send "aeChangingBackColorOfChunk" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingBackColorOfChunk" is not in the pendingmessages then
            send "aeChangingBackColorOfChunk" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingBackColorOfChunk

------
local sAELockforecolorOfChunkChanging, tAeChangeforecolorOfChunk

on aeChangeforecolorOfChunk
   local tControl, tforecolorOfChunk, tDuration, tMethod, tParameters, tCurrentforecolorOfChunk, tChunk

   if sAEFrameRate is empty then aeResetFrameRate
   --   if "animationEngine" is not among the lines of the openstacks then
   -- -- Das selbe Spiel. *Spuck*
   --      local tDefault
   --      put the defaultstack into tDefault
   --      open inv "animationEngine"
   --      set the defaultstack to tDefault
   --   end if
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat

   put item 1 of tParameters into tControl
   put item 2 of tParameters into tChunk
   local tTest, tTest2
   put tChunk && "of" && tControl into tTest
   try
      get tTest
   catch theErr
      return "aeError: Could not evaluate " && tchunk && "of" && tControl
   end try
   put tTest into tTest2
   if word 1 of tTest2 = "char" then
      repeat with i = 1 to the number of words of tTest2
         if word i of tTest2 = "of" then exit repeat
      end repeat
      put "char 1 of" into word 1 to i of tTest2
    else
      put "char 1 of" && tTest into tTest2
   end if
   if item 3 of tParameters is a color and item 2 of tParameters is not a number then
      -- we got no RGB values here
      set the backcolor of grc "testColor" of me to item 3 of tParameters

      set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me

      put the backcolor of grc "testColor" of me into tforecolorOfChunk

      put item 4 of tParameters into tDuration
      put item 5 of tParameters into tMethod
    else
      put item 3 to 5 of tParameters into tforecolorOfChunk
      put item 6 of tParameters into tDuration
      put item 7 of tParameters into tMethod
   end if
   if there is no tControl then return "error:" && tControl && "is not a valid control or group or stack"
   if tforecolorOfChunk is not a color then return "error:" && tforecolorOfChunk && "is not a valid color"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tMethod && "is not a valid easing method. Must be in,out or inOut"
   set the backcolor of grc "testColor" of me to the effective forecolor of tTest2
   set the backpixel of grc "testColor" of me to the effective backpixel of grc "testColor" of me
   put the backcolor of grc "testColor" of me into tCurrentforecolorOfChunk
   local tKey
   put (tControl & "," & tChunk) into tKey
   if not sAELockforecolorOfChunkChanging then
      put tforecolorOfChunk, tChunk, tDuration, tMethod, tCurrentforecolorOfChunk, the milliseconds into tAeChangeforecolorOfChunk[tKey]
      if "aeChangingforecolorOfChunk" is not in the pendingmessages then
         aeChangingforecolorOfChunk
      end if
    else
      put tforecolorOfChunk, tChunk, tDuration, tMethod, tCurrentforecolorOfChunk, "pending" into tAeChangeforecolorOfChunk[tKey]
   end if

end aeChangeforecolorOfChunk

on aeLockforecolorOfChunks
   put true into sAELockforecolorOfChunkChanging
end aeLockforecolorOfChunks

on aeUnlockforecolorOfChunks
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAeChangeforecolorOfChunk
      if item 6 of tAeChangeforecolorOfChunk[pControl] <> "pending" then next repeat
      put tNow into item 6 of tAeChangeforecolorOfChunk[pControl]
   end repeat
   put false into sAELockforecolorOfChunkChanging
   if "aeChangingforecolorOfChunk" is not in the pendingmessages then aeChangingforecolorOfChunk
end aeUnlockforecolorOfChunks

local sTimeTakenToChangeforecolorOfChunks

command aeChangingforecolorOfChunk
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tforecolorOfChunk, tDuration, tMethod, tStartforecolorOfChunk, tDestforecolorOfChunk, tStartTime, tChunk
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeforecolorOfChunks into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeforecolorOfChunks
   local theControl
   repeat for each line pControl in the keys of tAeChangeforecolorOfChunk
      put item 1 of pControl into theControl
      send "aeEnterFrame" && "aeChangeForeColorOfChunk" to theControl
      put item 1 to 3 of tAeChangeforecolorOfChunk[pControl] into tDestforecolorOfChunk
      put item 4 of tAeChangeforecolorOfChunk[pControl] into tChunk
      put item 5 of tAeChangeforecolorOfChunk[pControl] into tDuration
      put item 6 of tAeChangeforecolorOfChunk[pControl] into tMethod
      put item 7 to 9 of tAeChangeforecolorOfChunk[pControl] into tStartforecolorOfChunk
      put item 10 of tAeChangeforecolorOfChunk[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(item 1 of tStartforecolorOfChunk, item 1 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 1 of tforecolorOfChunk
            put aeEaseIn(item 2 of tStartforecolorOfChunk, item 2 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 2 of tforecolorOfChunk
            put aeEaseIn(item 3 of tStartforecolorOfChunk, item 3 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 3 of tforecolorOfChunk
            break
         case "out"
            put aeEaseOut(item 1 of tStartforecolorOfChunk, item 1 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 1 of tforecolorOfChunk
            put aeEaseOut(item 2 of tStartforecolorOfChunk, item 2 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 2 of tforecolorOfChunk
            put aeEaseOut(item 3 of tStartforecolorOfChunk, item 3 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 3 of tforecolorOfChunk
            break
         case "inOut"
            put aeEaseInOut(item 1 of tStartforecolorOfChunk, item 1 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 1 of tforecolorOfChunk
            put aeEaseInOut(item 2 of tStartforecolorOfChunk, item 2 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 2 of tforecolorOfChunk
            put aeEaseInOut(item 3 of tStartforecolorOfChunk, item 3 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 3) into item 3 of tforecolorOfChunk
            break
         case "bounce"
            put aeBounceEaseOut(item 1 of tStartforecolorOfChunk, item 1 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime) into item 1 of tforecolorOfChunk
            put aeBounceEaseOut(item 2 of tStartforecolorOfChunk, item 2 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime) into item 2 of tforecolorOfChunk
            put aeBounceEaseOut(item 3 of tStartforecolorOfChunk, item 3 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime) into item 3 of tforecolorOfChunk
            break
         case "overshoot"
            put aeOverShootEaseOut(item 1 of tStartforecolorOfChunk, item 1 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime) into item 1 of tforecolorOfChunk
            put aeOverShootEaseOut(item 2 of tStartforecolorOfChunk, item 2 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime) into item 2 of tforecolorOfChunk
            put aeOverShootEaseOut(item 3 of tStartforecolorOfChunk, item 3 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime) into item 3 of tforecolorOfChunk
            break
         default
            put aeEaseIn(item 1 of tStartforecolorOfChunk, item 1 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 1) into item 1 of tforecolorOfChunk
            put aeEaseIn(item 2 of tStartforecolorOfChunk, item 2 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 1) into item 2 of tforecolorOfChunk
            put aeEaseIn(item 3 of tStartforecolorOfChunk, item 3 of tDestforecolorOfChunk, tDuration, the milliseconds - tStartTime, 1) into item 3 of tforecolorOfChunk
            break
      end switch

      repeat with i = 1 to 3
         put round(item i of tforecolorOfChunk) into item i of tforecolorOfChunk
         if item i of tforecolorOfChunk > 255 then put 255 into item i of tforecolorOfChunk
         if item i of tforecolorOfChunk < 0 then put 0 into item i of tforecolorOfChunk
      end repeat
      local assembleChunk
      put tChunk & " of " & item 1 of pControl into assembleChunk
      if the milliseconds - tStartTime < tDuration then
         do "set the forecolor of" && assembleChunk && "to" && tforecolorOfChunk
       else
         if tforecolorOfChunk is a color then
            do "set the forecolor of" && assembleChunk && "to" && tforecolorOfChunk
         end if
         delete variable tAeChangeforecolorOfChunk[pControl]
         dispatch "aeChangeforecolorOfChunkDone" to theControl
      end if
      send "aeExitFrame" && "aeChangeForeColorOfChunk" to theControl
   end repeat
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAeChangeforecolorOfChunk is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingforecolorOfChunk" is not in the pendingmessages then
            send "aeChangingforecolorOfChunk" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingforecolorOfChunk" is not in the pendingmessages then
            send "aeChangingforecolorOfChunk" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingforecolorOfChunk

-- stop stuff

on aeStopChangingForeColorOfChunk tControl, tChunk
   local tKey
   put (tControl & "," & tChunk) into tKey
   if tControl = "all" then
      delete variable tAeChangeforecolorOfChunk
    else
      delete variable tAeChangeforecolorOfChunk[tKey]
   end if
end aeStopChangingForeColorOfChunk

on aeStopChangingBackColorOfChunk tControl, tChunk
   local tKey
   put (tControl & "," & tChunk) into tKey
   if tControl = "all" then
      delete variable tAeChangeBackcolorOfChunk
    else
      delete variable tAeChangeBackcolorOfChunk[tKey]
   end if
end aeStopChangingBackColorOfChunk

on aeStopChangingVscroll tControl
   if tControl = "all" then
      delete variable tAEChangeVscroll
    else
      delete variable tAEChangeVscroll[the long id of tControl]
   end if
end aeStopChangingVScroll

on aeStopChangingHscroll tControl
   if tControl = "all" then
      delete variable tAEChangeHscroll
    else
      delete variable tAEChangeHscroll[the long id of tControl]
   end if
end aeStopChangingHScroll

on aeStopChangingThumbposition tControl
   if tControl = "all" then
      delete variable tAEChangeThumbposition
    else
      delete variable tAEChangeThumbposition[the long id of tControl]
   end if
end aeStopChangingThumbposition

on aeStopChangingHeight tControl
   if tControl = "all" then
      delete variable tAEChangeHeight
    else
      delete variable tAEChangeHeight[the long id of tControl]
   end if
end aeStopChangingHeight

on aeStopChangingWidth tControl
   if tControl = "all" then
      delete variable tAEChangeWidth
    else
      delete variable tAEChangeWidth[the long id of tControl]
   end if
end aeStopChangingWidth

on aeStopChangingRect tControl
   if tControl = "all" then
      delete variable tAEChangeRect
    else
      delete variable tAEChangeRect[the long id of tControl]
   end if
end aeStopChangingRect

on aeStopChangingBackColor tControl
   if tControl = "all" then
      delete variable tAEChangeBackColor
    else
      delete variable tAEChangeBackColor[the long id of tControl]
   end if
end aeStopChangingBackColor

on aeStopChangingForeColor tControl
   if tControl = "all" then
      delete variable tAEChangeForeColor
    else
      delete variable tAEChangeForeColor[the long id of tControl]
   end if
end aeStopChangingForeColor

on aeStopMorphing tControl
   if tControl = "all" then
      delete variable sAEMorphing
    else
      delete variable sAEMorphing[the long id of tControl]
   end if
end aeStopMorphing

--> 4.0 update

on aeScrollTo
   local tControl, tX, tY, tDuration, tMethod, tParameters
   if sAEFrameRate is empty then aeResetFrameRate
   repeat with i = 1 to paramcount()
      if i < paramcount() then
         put param(i) & "," after tParameters
       else
         put param(i) after tParameters
      end if
   end repeat
   put item 1 of tParameters into tControl
   put item 2 of tParameters into tX
   put item 3 of tParameters into tY
   put item 4 of tParameters into tDuration
   put item 5 of tParameters into tMethod
   if there is no tControl then return "error:" && tControl && "is not a valid group or field"
   if word 1 of the long name of tControl <> "group" and word 1 of the long name of tControl <> "field" then return "error: can only scroll groups or fields"
   if tX is not an integer then return "error:" && tX & "," & tY && "is not a valid scroll"
   if tY is not an integer then return "error:" && tX & "," & tY && "is not a valid scroll"
   if tduration is not a number then return "error:" && tDuration && "is not a valid duration"
   if tMethod is not among the items of ",in,out,inout,bounce,overshoot" then return "error:" && tDuration && "is not a valid easing method. Must be in, out, inOut, bounce or overshoot"
   if not sAELockScrolls then
      put tX, tY, tDuration, tMethod, the hscroll of tControl, the vscroll of tControl, the milliseconds into tAeScrolling[the long id of tControl]
      if "aeChangingScroll" is not in the pendingmessages then
         aeChangingScroll
      end if
    else
      put tX, tY, tDuration, tMethod, the hscroll of tControl, the vscroll of tControl, "pending" into tAeScrolling[the long id of tControl]
   end if
end aeScrollTo

on aeLockScrolls
   put true into sAELockScrolls
end aeLockScrolls

on aeUnlockScrolls
   local tNow
   put the milliseconds into tNow
   repeat for each line pControl in the keys of tAEScrolling
      if item 7 of tAEScrolling[pControl] <> "pending" then next repeat
      put tNow into item 7 of tAEScrolling[pControl]
   end repeat
   put false into sAeLockScrolls
   if "aeChangingScroll" is not in the pendingmessages then aeChangingScroll
end aeUnlockScrolls

local sTimeTakenToChangeScroll

command aeChangingScroll
   --put the millisecs
   lock screen
   local tTimeLost, tFramesLost, tElapsed
   local tDuration, tMethod, tStartX, tDestX, tDestY, tStartY, tStartTime, tX, tY, tEndX
   if sAEFrameRate is not a number then aeResetFrameRate
   put the milliseconds into tElapsed
   put the milliseconds - sTimeTakenToChangeScroll into tTimeLost
   put tTimeLost - (1000 / sAEFrameRate) into tTimeLost
   put ((1000 / sAeFramerate) + tTimeLost) into tFramesLost
   if tFramesLost <> 0 then
      put 1000 / tFramesLost into tFramesLost
   end if
   if tFramesLost > sAEFrameRate then put sAEFrameRate into tFramesLost
   put tFramesLost into sAERealFrameRate
   put the millisecs into sTimeTakenToChangeScroll
   --lock screen
   repeat for each line pControl in the keys of tAEScrolling
      send "aeEnterFrame" && "aeScrollTo" to pcontrol
      put item 1 of tAEScrolling[pControl] into tDestX
      put item 2 of tAEScrolling[pControl] into tDestY
      put item 3 of tAEScrolling[pControl] into tDuration
      put item 4 of tAEScrolling[pControl] into tMethod
      put item 5 of tAEScrolling[pControl] into tStartX
      put item 6 of tAEScrolling[pControl] into tStartY
      put item 7 of tAEScrolling[pControl] into tStartTime
      if tStartTime = "pending" then next repeat
      switch tMethod
         case "in"
            put aeEaseIn(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 3) into tX
            put aeEaseIn(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 3) into tY
            break
         case "out"
            put aeEaseOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 3) into tX
            put aeEaseOut(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 3) into tY
            break
         case "inOut"
            put aeEaseInOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 3) into tX
            put aeEaseInOut(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 3) into tY
            break
         case "bounce"
            put aeBounceEaseOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime) into tX
            put aeBounceEaseOut(tStartY, tDestY, tDuration, the milliseconds - tStartTime) into tY
            break
         case "overshoot"
            put aeOverShootEaseOut(tStartX, tDestX, tDuration, the milliseconds - tStartTime) into tX
            put aeOverShootEaseOut(tStartX, tDestY, tDuration, the milliseconds - tStartTime) into tY
            break
         default
            put aeEaseIn(tStartX, tDestX, tDuration, the milliseconds - tStartTime, 1) into tX
            put aeEaseIn(tStartY, tDestY, tDuration, the milliseconds - tStartTime, 1) into tY
            break
      end switch
      if the milliseconds - tStartTime < tDuration then
         set the hscroll of pControl to round(tX)
         set the vscroll of pControl to round(tY)
       else
         set the hscroll of pControl to round(tDestX)
         set the vscroll of pControl to round(tDestY)
         delete variable tAEScrolling[pControl]
         dispatch "aeChangeScrollDone" to pControl
      end if
      send "aeExitFrame" && "aeScrollTo" to pControl
   end repeat
   --   unlock screen
   unlock screen
   put the milliseconds - tElapsed into tElapsed
   if the keys of tAEScrolling is not empty then
      if tElapsed < 1000 / sAEFrameRate then
         if "aeChangingScroll" is not in the pendingmessages then
            send "aeChangingScroll" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeChangingScroll" is not in the pendingmessages then
            send "aeChangingScroll" to me in 5 millisecs
         end if
      end if
   end if
end aeChangingScroll

local aeCollisionListener, aelistenForCollisions

setProp aeListenForCollisionsWith pObjectList
   local tInvalidControls, tObjects
   repeat for each line theLine in pObjectList
      if there is no theLine then
         put theLine & cr after tInvalidControls
         next repeat
      end if
      put theLine & cr after tObjects
   end repeat
   delete char - 1 of tObjects
   delete char - 1 of tInvalidControls
   put tObjects into aeCollisionListener[the long name of the target]
   if tInvalidControls is not empty then
      return tInvalidControls
   end if
end aeListenForCollisionsWith

on aeStartListeningForCollisions
   put true into aeListenForCollisions
   if aeListenForCollisions is not in the pendingmessages then
      aeListenForCollisions
   end if
end aeStartListeningForCollisions

on aeStopListeningForCollisions
   put false into aeListenForCollisions
   repeat for each line theLine in the pendingmessages
      if "aeListenForCollisions" is in theLine then cancel item 1 of theLine
   end repeat
   delete variable aeCollisionListener
end aeStopListeningForCollisions

on aeListenForCollisions
   try
      if sAEFrameRate is empty then aeSetFrameRate 25
      local tObjects, tElapsed
      put the millisecs into tElapsed
      if not aeListenForCollisions then exit aeListenForCollisions
      repeat for each key theKey in aeCollisionListener
         put empty into tObjects
         repeat for each line theLine in aeCollisionListener[theKey]
            if intersect (theKey, theLine, "pixels") then
               put theLine & cr after tObjects
            end if
         end repeat
         delete char - 1 of tObjects
         if tObjects is not empty then
            dispatch "aeCollision" to theKey with tObjects
         end if
      end repeat
      put the millisecs - tElapsed into tElapsed
      if tElapsed < 1000 / sAEFrameRate then
         if "aeListenForCollisions" is not in the pendingmessages then
            send "aeListenForCollisions" to me in (1000 / sAEFRameRate) - tElapsed millisecs
         end if
       else
         if "aeListenForCollisions" is not in the pendingmessages then
            send "aeListenForCollisions" to me in 5 millisecs
         end if
      end if
   catch theErr
      throw theErr
   end try
end aeListenForCollisions


function aeCollidingObjects
   local tObjects, tReturn
   repeat for each key theKey in aeCollisionListener
      put empty into tObjects -- 5.0.4 fix for errant collision lists
      repeat for each line theLine in aeCollisionListener[theKey]
         if intersect (theKey, theLine, "pixels") then
            put theLine & cr after tObjects
         end if
      end repeat
      delete char - 1 of tObjects
      put tObjects into tReturn[theKey]
      if tReturn[theKey] is empty then delete variable tReturn[theKey]
   end repeat
   return tReturn
end aeCollidingObjects

-- contribution by Geoff Canyon

function rotate3DPointList pointList, pXRotation, pYRotation, pZRotation, pFocalLength
   local cX, cY, cZ, i
   local newX, newY, newZ
   local pX, pY
   local pZ, tScaleFactor, sX
   local sY, sZ, tParameters, xY
   local xZ, yX, yZ, zX
   local zY
   local tReturnList
   if pFocalLength is empty then put 300 into pFocalLength
   put pXrotation * pi / 180 into pXrotation
   put pYrotation * pi / 180 into pYrotation
   put pZrotation * pi / 180 into pZrotation
   put sin(pXRotation) into sX
   put cos(pXRotation) into cX
   put sin(pYRotation) into sY
   put cos(pYRotation) into cY
   put sin(pZRotation) into sZ
   put cos(pZRotation) into cZ
   try
      repeat for each line L in pointList
         if L is empty then
            put cr after tReturnList
            next repeat
         end if
         put item 1 of L into pX
         put item 2 of L into pY
         put item 3 of L into pZ
         -- rotation around x
         put cx * pY - sx * pZ into xY
         put sx * pY + cx * pZ into xZ
         -- rotation around y
         put cy * xz - sy * pX into yZ
         put sy * xz + cy * pX into yX
         -- rotation around z
         put cz * yx - sz * xy into zX
         put sz * yx + cz * xy into zY
         put pfocalLength / (pfocalLength + yz) into tScaleFactor
         put zX * tScalefactor into newX
         put zY * tScalefactor into newY
         put yZ into newZ
         put newX, newY, newZ & cr after tReturnList
      end repeat
      return char 1 to - 2 of tReturnList
   catch theError
      return theError
   end try
end rotate3DPointList

function ae3dConvertListToScreen pointList, pOriginX, pOriginY, pFocalLength
   local i
   local pX, pY, pZ, tParameters
   local tScaleFactor, tXCartesian, tYCartesian, tReturnList
   if pFocalLength is empty then put 300 into pFocalLength
   try
      repeat for each line L in pointList
         if L is empty then
            put cr after tReturnList
            next repeat
         end if
         put item 1 of L into pX
         put item 2 of L into pY
         put item 3 of L into pZ
         put pFocalLength / (pFocalLength + pZ) into tScaleFactor
         put pX * tScaleFactor into tXCartesian
         put pY * tScaleFactor into tYCartesian
         put round(tXCartesian + pOriginX), round(- tYCartesian + pOriginY) & cr after tReturnList
      end repeat
      return char 1 to - 2 of tReturnList
   catch theError
      return theError
   end try
end ae3dConvertListToScreen

####################### Added in version 7 ######################################
# This command is to create and update the value of the properties of the objects
# in the custom property set used by this library.
# The parameters are:
# - pLongId: The long id of the control
# - pProp: The name of the property
# - pValue: The value of the property
private command _setAnimationEngine pLongId, pProp, pValue
   if there is not a pLongId or pProp is empty then exit _setAnimationEngine
   set the cAnimationEngine[pProp] of pLongId to pValue
end _setAnimationEngine

# This function is to get the value of a property from the library's custom property set.
# If the property name is not specified, the full array is returned.
# The parameters are:
# - pLongId: The long id of the control
# - pProp: The name of the property
private function _getAnimationEngine pLongId, pProp
   local tAnimationEngineArray
   if there is not a pLongId then return empty
   put the customProperties["cAnimationEngine"]  of pLongId into tAnimationEngineArray
   if pProp is not empty then return tAnimationEngineArray [pProp]
   return tAnimationEngineArray
end _getAnimationEngine


private command _parameterFormat @pParam1, @pParam2, @pParam3, @pParam4, @pParam5, @pParam6, @pParam7, @pParam8
   local tParameters

   put pParam1, pParam2, pParam3, pParam4, pParam5, pParam6, pParam7, pParam8 into tParameters
   put item 1 of tParameters into pParam1
   put item 2 of tParameters into pParam2
   put item 3 of tParameters into pParam3
   put item 4 of tParameters into pParam4
   put item 5 of tParameters into pParam5
   put item 6 of tParameters into pParam6
   put item 7 of tParameters into pParam7
   put item 8 of tParameters into pParam8
end _parameterFormat
