require 'fileutils'
require 'json'
require 'logger'
RSpec.describe "fileutils", "#fix_entry" do
  it "should remove the _score, sort and _source fields, returning the remaining entry and the source" do
    $logger = Logger.new(STDOUT)
    expected_entry = JSON.parse('{"_index":"finalcutserver_file","_type":"fileref","_id":"AV-R-iT_MduHl_71_7Jy"}')
    expected_source = JSON.parse('{"ADDRESS":"/asset/100245","Thumbnail Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.jpg (file is missing)","Clip Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","server":"damserver.dc1.gnm.int","Archived Representation":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","Primary":"/Volumes/MultiMedia1/DAM/Media Library/LIB_ARCHMASTERS/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","None":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)"}')

    source = JSON.parse('{"_index":"finalcutserver_file","_type":"fileref","_id":"AV-R-iT_MduHl_71_7Jy","_score":1.0,"sort":"fdsjhsfd","_source":{"ADDRESS":"/asset/100245","Thumbnail Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.jpg (file is missing)","Clip Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","server":"damserver.dc1.gnm.int","Archived Representation":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","Primary":"/Volumes/MultiMedia1/DAM/Media Library/LIB_ARCHMASTERS/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","None":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)"}}')

    ap source
    results = fix_entry(source, [])

    expect(results[0]).to eq expected_entry
    expect(results[1]).to eq expected_source
  end

  it "should also filter out fields with blank names" do
    $logger = Logger.new(STDOUT)
    expected_entry = JSON.parse('{"_index":"finalcutserver_file","_type":"fileref","_id":"AV-R-iT_MduHl_71_7Jy"}')
    expected_source = JSON.parse('{"ADDRESS":"/asset/100245","Thumbnail Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.jpg (file is missing)","Clip Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","server":"damserver.dc1.gnm.int","Archived Representation":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","Primary":"/Volumes/MultiMedia1/DAM/Media Library/LIB_ARCHMASTERS/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","None":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)"}')

    source = JSON.parse('{"_index":"finalcutserver_file","_type":"fileref","_id":"AV-R-iT_MduHl_71_7Jy","_score":1.0,"sort":"fdsjhsfd","_source":{"ADDRESS":"/asset/100245","Thumbnail Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.jpg (file is missing)","":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.jpg (file is missing)","Clip Proxy":"/Volumes/Proxies/DAM_PROXY/Proxies.bundle/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","server":"damserver.dc1.gnm.int","Archived Representation":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","Primary":"/Volumes/MultiMedia1/DAM/Media Library/LIB_ARCHMASTERS/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)","None":"/Volumes/MegaArchive2/FCSvr_Archive/92/ MASTER_CITY_OF_WALLS_HD+MIXES-GUARDIAN VERSION_FINAL_ST_QT FOR WEB fixed.mov (file is missing)"}}')

    ap source
    results = fix_entry(source, [])

    expect(results[0]).to eq expected_entry
    expect(results[1]).to eq expected_source
  end
end
