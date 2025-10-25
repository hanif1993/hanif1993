procedure(CCSRemoveLppHierAll(LPP HierLevel @optional (cv geGetEditCellView()) "lnd")
let((boxArea tmpcv opencv shapeList shapeTable)

;;Check if a layout cell is open.
if(!cv then
error("No cellview open currently, please open a layout.\n")
else
if(cv~>cellViewType != "maskLayout" then
error("Currently open cellview is not a layout, please check.\n")
) ;if
) ;if

;; Automatically set the boxArea to the entire cellview's bounding box
boxArea = cv~>bBox
unless(boxArea
error("Could not get bounding box from cellview. Is the cell empty?")
)
printf("Automatically processing entire cellview area: %L\n" boxArea)

shapeList=leSearchHierarchy( cv boxArea HierLevel "any shape" list(list("layer" "==" LPP )))

/* The returned list may contain same shape ID multiple times. Because a cell having a
given
shape may be instantiated at multiple places in the hierarchy. Create a table of shapeList
and make sure that table has unique shape ID's by checking for duplicate entries in the
foreach loop below */

shapeTable=makeTable('shapeTable)
foreach(shape shapeList
shapeTable[shape]=t
)

foreach(shape shapeTable
;;
;; **FIX:** Properly commented out this line
;; Refrain from going inside pcells and vias
unless(shape~>cellView~>superMaster ||shape~>cellView~>mode=="s"
if(dbReopen(shape~>cellView "a") then
tmpcv=shape~>cellView
opencv=cons(tmpcv opencv)
dbDeleteObject(shape)
dbSave(tmpcv)
);if
) ;unless
);foreach

let((uniqueModifiedCVs cellNames)
  uniqueModifiedCVs = CCSRemoveDuplicateElem(opencv)

  if(uniqueModifiedCVs then
    cellNames = nil
    foreach(cv uniqueModifiedCVs
      cellNames = cons(cv~>cellName cellNames)
    )
    cellNames = reverse(cellNames)
    hiDisplayAppDBox(
      ?name 'CCSModifiedCellsDBox
      ?dboxBanner "List of Modified Cells"
      ?dboxText strcat("The following cells have been modified:\n\n" buildString(cellNames "\n"))
      ?buttons '("OK")
    )
  else
    hiDisplayAppDBox(
      ?name 'CCSNoShapesDeletedDBox
      ?dboxBanner "List of Modified Cells"
      ?dboxText "No Shape Deleted."
      ?buttons '("OK")
    )
  ) ;if

  foreach(cvid uniqueModifiedCVs dbClose(cvid))
) ;let
printf("Done deleting the shapes on LPP:%L\n" LPP)

);let
);procedure

procedure(CCSRemoveDuplicateElem(aList)
let((uList)
uList=nil
foreach(x aList
unless(member(x uList)
uList=cons(x uList)
) ;if
) ;foreach
reverse(uList)
) ; let
) ;procedure CCSRemoveDuplicateElem
