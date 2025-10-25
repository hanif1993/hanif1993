; CCSGetNets_LayersInfo(list("net086" "net80") 0 0 t)

procedure( CCSGetNetTracedInfo(window netName startLvl stopLvl CreateCVs)
let((myTraces netTable signame shapes objType Net_bBox layerName layerPurpose key cellView)
lntRemoveAll()
printf("Tracing Net:%s\n" netName)
lntAddTrace(window netName ?startLevel startLvl ?stopLevel stopLvl)
myTraces = nil
netTable = makeTable("netTable" nil)
when(cellView = geGetWindowCellView(window)
myTraces = lntGetAllTraces(cellView)
when(myTraces
foreach(myTrace myTraces
signame=car(cadr(lntGetTraceInfo(myTrace))~>sigNames)
shapes=cadr(lntGetTraceInfo(myTrace))~>shapes
foreach(shape shapes
objType=shape~>objType
layerName=car(shape~>lpp)
layerPurpose=cadr(shape~>lpp)
case(objType
( ("path" "polygon")
Net_bBox= list(shape~>points)
)
("pathSeg"
Net_bBox= list(shape~>beginPt shape~>endPt)
)
("rect"
Net_bBox= list(shape~>bBox)
)
);case

key=sprintf(nil "%s_%s_%s_%s" signame layerName layerPurpose objType)
unless(member(Net_bBox netTable[key])
netTable[key]=append1(netTable[key] Net_bBox)
);unless
);foreach
) ;foreach
);when
);when cv
when(CreateCVs
lntSaveTraces(window myTraces cellView~>libName cellView~>cellName strcat(cellView~>viewName "_" netName "_netTracer"))
)
lntRemoveAll()
netTable
);let
);procedure

procedure(CCSTransformNetData(netData)
  let((layerTable layer purpose shapeType)
    layerTable = makeTable('layerTable)
    foreach(key netData~>?
      keyParts = parseString(key "_")
      layer = cadr(keyParts)
      purpose = caddr(keyParts)
      shapeType = nth(3 keyParts)
      unless(isTable(layerTable[layer])
        layerTable[layer] = makeTable('purposeTable)
      )
      layerTable[layer][sprintf(nil "%s %s" purpose shapeType)] = length(netData[key])
    )
    layerTable
  )
)

procedure(_CCSFindNetRecursive(cv point)
  let((fig net newPoint)
    net = nil
    fig = car(lePointToFig(cv point))
    if(fig then
      if(fig~>net then
        net = fig~>net
      else
        if(fig~>objType == "inst" then
          newPoint = dbTransformPoint(point dbInvertTransform(fig~>transform))
          net = _CCSFindNetRecursive(fig~>master newPoint)
        )
      )
    )
    net
  )
)

procedure(_CCSRemoveDuplicates(inList)
  let((outList)
    outList = nil
    foreach(item inList
      unless(member(item outList)
        outList = cons(item outList)
      )
    )
    reverse(outList)
  )
)

procedure( CCSGetNets_LayersInfo(@optional (Signames nil) (startLvl 0) (stopLvl 0) (InfoCoords nil) (CreateCVs nil) (LogFile "./CCSGetNets_LayersInfo.txt") )
  let((outPort win result print_lines print_line transformedData)

    outPort=outfile(LogFile)
    poport=outPort
    woport=outPort
    errport=outPort

    win=hiGetCurrentWindow()

    foreach( sig Signames
      result=CCSGetNetTracedInfo(win sig startLvl stopLvl CreateCVs)
      transformedData = CCSTransformNetData(result)
      print_line=sprintf(nil "Net: %s" sig)
      print_lines = append1(print_lines print_line)

      foreach(layer sort(transformedData->? nil)
        print_line = sprintf(nil "  Layer: %s" layer)
        print_lines = append1(print_lines print_line)
        foreach(purposeShape sort(transformedData[layer]->? nil)
          print_line = sprintf(nil "    - %s: %d shapes" purposeShape transformedData[layer][purposeShape])
          print_lines = append1(print_lines print_line)
        )
      )
    );foreach sig
    poport=stdout
    errport=stderr
    woport=stdout

    foreach(tmp print_lines
      printf("%s\n" tmp)
      fprintf(outPort "%s\n" tmp)
    )
    fprintf(outPort "Processed %L number of Nets\n" length(Signames))
    close(outPort)

    printf("Processed %L number of Nets\n" length(Signames))
  );let
);procedure

procedure( CCSCreateNetInfoForm()
  let( (netNameField selectButton)
    netNameField = hiCreateStringField(
      ?name 'netNames
      ?prompt "Net Names"
      ?value ""
    )
    selectButton = hiCreateButton(
      ?name 'selectButton
      ?buttonText "Select Nets from Layout"
      ?callback "CCSSelectNets()"
    )
    hiCreateAppForm(
      ?name 'CCSNetInfoForm
      ?formTitle "Net Information Reporter"
      ?fields list(
        list(netNameField 0:0 300:30 150)
        list(selectButton 0:40 300:30)
      )
      ?callback 'CCSSubmitNetInfoFormCB
      ?buttonLayout 'OKCancel
    )
  )
)

procedure(CCSSelectNets()
  let((selectedNets)
    geSelectFig(nil)
    enterPoints(
      ?prompts '("Select shapes to get net names from. Press DONE when finished.")
      ?doneProc "CCSProcessSelectedNets"
    )
  )
)

procedure(CCSProcessSelectedNets(done points)
  let((netNames currentNames windowId net cv)
    netNames = nil
    cv = geGetWindowCellView()
    foreach(point points
      net = _CCSFindNetRecursive(cv point)
      when(net
        netNames = adjoin(net~>name netNames)
      )
    )
    currentNames = CCSNetInfoForm->netNames->value
    if(currentNames && currentNames != "" then
      netNames = nconc(parseString(currentNames " ") netNames)
    )
    CCSNetInfoForm->netNames->value = buildString(sort(_CCSRemoveDuplicates(netNames) nil) " ")
  )
)

procedure(CCSSubmitNetInfoFormCB(form)
  let((netNameString netNameList uniqueNetList)
    netNameString = form->netNames->value
    when( netNameString && netNameString != ""
      netNameList = parseString(netNameString " ")
      uniqueNetList = _CCSRemoveDuplicates(netNameList)
      CCSGetNets_LayersInfo(uniqueNetList)
    )
    hiFormDone(form)
  )
)

procedure(CCSRunNetInfo()
  if( !boundp('CCSNetInfoForm) || CCSNetInfoForm->window == nil then
    CCSCreateNetInfoForm()
    hiDisplayForm(CCSNetInfoForm)
  else
    hiRaiseWindow(CCSNetInfoForm~>window)
  )
)