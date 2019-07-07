-- suriwire
-- A wireshark plugin to integrate suricata alerts and logs in wireshark
-- pcap output.
--
-- Version 2.0.
--
-- Wireshark - Network traffic analyzer
-- By chiaifan

-- local json = require("json")
local json = loadfile("dkjson.lua")();

if (gui_enabled()) then 
	local suri_proto = Proto("suricata", "Suricata Analysis")
	local suri_gid = ProtoField.string("suricata.alert.gid", "GID", FT_INTEGER)
	local suri_sid = ProtoField.string("suricata.alert.sid", "SID", FT_INTEGER)
	local suri_rev = ProtoField.string("suricata.alert.rev", "Rev", FT_INTEGER)
	local suri_msg = ProtoField.string("suricata.alert.msg", "Message", FT_STRING)
	local suri_tls_subject = ProtoField.string("suricata.tls.subject", "TLS subject", FT_STRING)
	local suri_tls_issuerdn = ProtoField.string("suricata.tls.issuerdn", "TLS issuer DN", FT_STRING)
	local suri_tls_fingerprint = ProtoField.string("suricata.tls.fingerprint", "TLS fingerprint", FT_STRING)
	local suri_tls_version = ProtoField.string("suricata.tls.version", "TLS version", FT_STRING)

	local suri_ssh_client_version = ProtoField.string("suricata.ssh.client.version", "SSH client version", FT_STRING)
	local suri_ssh_client_proto = ProtoField.string("suricata.ssh.client.proto", "SSH client protocol", FT_STRING)
	local suri_ssh_server_version = ProtoField.string("suricata.ssh.server.version", "SSH server version", FT_STRING)
	local suri_ssh_server_proto = ProtoField.string("suricata.ssh.server.proto", "SSH server protocol", FT_STRING)

	local suri_fileinfo_filename = ProtoField.string("suricata.fileinfo.filename", "Fileinfo filename", FT_STRING)
	local suri_fileinfo_magic = ProtoField.string("suricata.fileinfo.magic", "Fileinfo magic", FT_STRING)
	local suri_fileinfo_md5 = ProtoField.string("suricata.fileinfo.md5", "Fileinfo md5", FT_STRING)
	local suri_fileinfo_size = ProtoField.string("suricata.fileinfo.size", "Fileinfo size", FT_INTEGER)
	local suri_fileinfo_stored = ProtoField.string("suricata.fileinfo.stored", "Fileinfo stored", FT_STRING)

	local suri_http_url = ProtoField.string("suricata.http.url", "HTTP URL", FT_STRING)
	local suri_http_hostname = ProtoField.string("suricata.http.hostname", "HTTP hostname", FT_STRING)
	local suri_http_user_agent = ProtoField.string("suricata.http.user_agent", "HTTP user agent", FT_STRING)
	local suri_http_content_type = ProtoField.string("suricata.http.content_type", "HTTP Content Type", FT_STRING)
	local suri_http_method = ProtoField.string("suricata.http.method", "HTTP Method", FT_STRING)
	local suri_http_protocol = ProtoField.string("suricata.http.protocol", "HTTP Protocol", FT_STRING)
	local suri_http_status = ProtoField.string("suricata.http.status", "HTTP Status", FT_STRING)
	local suri_http_length = ProtoField.string("suricata.http.length", "HTTP Length", FT_STRING)

	local suri_prefs = suri_proto.prefs
	local suri_running = false

	local suri_alerts = {}

	suri_prefs.suricata = Pref.string("Suricata binary", "/usr/bin/suricata",
					    "Path to suricata binary")
	suri_prefs.config_file = Pref.string("Suricata configuration", "/etc/suricata/suricata.yaml",
					    "Alert file containing information about pcap")
	suri_prefs.alert_file = Pref.string("EVE file", "c:\\suricata\\log\\eve.json",
					    "EVE file containing information about pcap")
	-- suri_prefs.copy_alert_file = Pref.bool("Make a copy of alert file", true,
	--				       "When running suricata, create a copy of alert"
	--				       .. " file in the directory of the pcap file")
	suri_proto.fields = {suri_gid, suri_sid, suri_rev, suri_msg, suri_tls_subject, suri_tls_issuerdn, suri_tls_fingerprint, suri_tls_version,
				suri_ssh_client_version, suri_ssh_client_proto, suri_ssh_server_version, suri_ssh_server_proto,
				suri_fileinfo_filename, suri_fileinfo_magic, suri_fileinfo_md5, suri_fileinfo_size, suri_fileinfo_stored, 
				suri_http_url, suri_http_hostname, suri_http_user_agent,
				suri_http_content_type, suri_http_method, suri_http_protocol, suri_http_status, suri_http_length
				}


	function suri_proto.dissector(buffer,pinfo,tree)
		if not(suri_alerts[pinfo.number] == nil) then
			for i, val in ipairs(suri_alerts[pinfo.number]) do
				if val['sid'] then
					subtree = tree:add(suri_proto,
							"Suricata alert: "..val['sid'].." ("..val['msg']..")")
					-- add protocol fields to subtree
					subtree:add(suri_gid, val['gid'])
					subtree:add(suri_sid, val['sid'])
					subtree:add(suri_rev, val['rev'])
					subtree:add(suri_msg, val['msg'])
					subtree:add_expert_info(PI_MALFORMED, PI_WARN, val['msg'])
				elseif val['tls_subject'] then
					subtree = tree:add(suri_proto, "Suricata TLS Info")
					-- add protocol fields to subtree
					subtree:add(suri_tls_subject, val['tls_subject'])
					subtree:add(suri_tls_issuerdn, val['tls_issuerdn'])
					subtree:add(suri_tls_fingerprint, val['tls_fingerprint'])
					subtree:add(suri_tls_version, val['tls_version'])
					subtree:add_expert_info(PI_REASSEMBLE, PI_NOTE, 'TLS Info')
				elseif val['ssh_client_version'] then
					subtree = tree:add(suri_proto, "Suricata SSH Info")
					-- add protocol fields to subtree
					subtree:add(suri_ssh_client_version, val['ssh_client_version'])
					subtree:add(suri_ssh_client_proto, val['ssh_client_proto'])
					subtree:add(suri_ssh_server_version, val['ssh_server_version'])
					subtree:add(suri_ssh_server_proto, val['ssh_server_proto'])
					subtree:add_expert_info(PI_REASSEMBLE, PI_NOTE, 'SSH Info')
				elseif val['fileinfo_filename'] then
					subtree = tree:add(suri_proto, "Suricata File Info")
					-- add protocol fields to subtree
					subtree:add(suri_fileinfo_filename, val['fileinfo_filename'])
					subtree:add(suri_fileinfo_magic, val['fileinfo_magic'])
					if val['fileinfo_md5'] then
						subtree:add(suri_fileinfo_md5, val['fileinfo_md5'])
					end
					subtree:add(suri_fileinfo_size, val['fileinfo_size'])
					subtree:add(suri_fileinfo_stored, val['fileinfo_stored'])
				end
				if val['http_url'] then
					subtree = tree:add(suri_proto, "Suricata HTTP Info")
					-- add protocol fields to subtree
					subtree:add(suri_http_url, val['http_url'])
					subtree:add(suri_http_hostname, val['http_hostname'])
					if val['http_user_agent'] then
						subtree:add(suri_http_user_agent, val['http_user_agent'])
					end
					if val['http_content_type'] then
						subtree:add(suri_http_content_type, val['http_content_type'])
					end
					if val['http_method'] then
						subtree:add(suri_http_method, val['http_method'])
					end
					if val['http_protocol'] then
						subtree:add(suri_http_protocol, val['http_protocol'])
					end
					if val['http_status'] then
						subtree:add(suri_http_status, val['http_status'])
					end
					if val['http_length'] then
						subtree:add(suri_http_length, val['http_length'])
					end
				end
		     end
	     end
	end

	function suri_proto.init()
	end

	-- register our protocol as a postdissector
	function suriwire_activate()
		function suriwire_parser(file)
			local event
			local id = 0
			local s_text = ""
			suri_alerts = {}
			for s_text in io.lines(file) do
				if s_text == nil then
					break
				elseif s_text ~= nil then
					event = json.decode(s_text)
					id = event["pcap_cnt"]
					-- print (id)
					if not (id == nil) then
						if event["event_type"] == "alert" then
							if suri_alerts[id] == nil then
								suri_alerts[id] = {}
							end
							table.insert(suri_alerts[id],
								{gid = tonumber(event["alert"]["gid"]), sid = tonumber(event["alert"]["signature_id"]),
								rev = tonumber(event["alert"]["rev"]), msg = event["alert"]["signature"]})
							print (suri_alerts)    
						elseif event["event_type"] == "tls" then
							if suri_alerts[id] == nil then
								suri_alerts[id] = {}
							end
							table.insert(suri_alerts[id],
								{ tls_subject = event["tls"]["subject"], tls_issuerdn = event["tls"]["issuerdn"],
								tls_fingerprint = event["tls"]["fingerprint"], tls_version = event["tls"]["version"]})
						elseif event["event_type"] == "ssh" then
							if suri_alerts[id] == nil then
								suri_alerts[id] = {}
							end
							table.insert(suri_alerts[id],
								{ ssh_client_version = event["ssh"]["client"]["software_version"],
								ssh_client_proto = event["ssh"]["client"]["proto_version"],
								ssh_server_version = event["ssh"]["server"]["software_version"],
								ssh_server_proto = event["ssh"]["server"]["proto_version"],
								})
						elseif event["event_type"] == "fileinfo" then
							if suri_alerts[id] == nil then
								suri_alerts[id] = {}
							end
							table.insert(suri_alerts[id],
								{ fileinfo_filename = event["fileinfo"]["filename"],
								fileinfo_magic = event["fileinfo"]["magic"],
								fileinfo_md5 = event["fileinfo"]["md5"],
								fileinfo_size = tonumber(event["fileinfo"]["size"]),
								fileinfo_stored = tostring(event["fileinfo"]["stored"]),
								http_url = event["http"]["url"],
								http_hostname = event["http"]["hostname"],
								http_user_agent = event["http"]["http_user_agent"],
								})
						elseif event["event_type"] == "http" then
							if suri_alerts[id] == nil then
								suri_alerts[id] = {}
							end
							table.insert(suri_alerts[id],
								{
									http_url = event["http"]["url"],
									http_hostname = event["http"]["hostname"],
									http_user_agent = event["http"]["http_user_agent"],
									http_content_type = event["http"]["http_content_type"],
									http_method = event["http"]["http_method"],
									http_protocol = event["http"]["protocol"],
									http_status = event["http"]["status"],
									http_length = event["http"]["length"],
								})
						end
					end    
				end
			end
		end

		function suriwire_register(file)
			if file == "" then
				file = suri_prefs.alert_file
			end
			local filehandle = io.open(file, "r")

			if not (filehandle == nil) then
				filehandle:close()
				-- parse suricata log file
				suriwire_parser(file)
				-- register protocol dissector
				if suri_running == false then
					register_postdissector(suri_proto)
					suri_running = true
				end
				reload()
			else
				new_dialog("Unable to open '" .. file
					   .. "'. Choose another alert file",
					   suriwire_register
					   "Choose file (default:" .. suri_prefs.alert_file..")")
			end
		end
		-- run suricata
		-- set input file
		new_dialog("Choose alert file",
			   suriwire_register,
			   "Choose file (default:" .. suri_prefs.alert_file..")")
		-- debug 1.7 
		-- suriwire_register("sample.log")
	end
	

	function suriwire_page()
		browser_open_url("http://home.regit.org/software/suriwire")
	end

	function suriwire_run()
		function getfilename(filepath)
			if getfilename ~= nil then
				local os = require"os"
				local command=suri_prefs.suricata.." -c "..suri_prefs.config_file.." -r "..filepath
				local exec=os.execute(command)
				
			end
		end
		new_dialog("Choose alert file",
			   getfilename,
			   "Plase check suricat and yaml config,Choose file suricata anyanis pcap:")
	end
	register_menu("Suricata/Run Suricata", suriwire_run, MENU_TOOLS_UNSORTED)
	register_menu("Suricata/Activate", suriwire_activate, MENU_TOOLS_UNSORTED)
	register_menu("Suricata/Web", suriwire_page, MENU_TOOLS_UNSORTED)
	-- debug 1.7
	-- suriwire_activate()
end