package provide 9pm::scp 1.0


proc scp_create_remote_string { NODE USER PATHS } {
    set         IP      [get_req_node_info $NODE SSH_IP]
    set         conn_str ""
    if { $USER == "" } {
        set     USER   [get_node_info $NODE SSH_USER]
    }
    if { $USER != "" } {
        append  conn_str "$USER@"
    }
    return "$conn_str$IP:$PATHS"
}

proc scp_create_file_list {FILES} {
    if { $FILES == "" } {
        fatal result FAIL "scp: Missing files to transfer"
    } else {
        return "{[join $FILES ","]} "
    }
}

proc scp_create_args {NODE} {
    set         PORT        [get_node_info $NODE SSH_PORT]
    set         KEYFILE     [get_node_info $NODE SSH_KEYFILE]
    set         EXTRA_ARGS  [get_node_info $NODE SCP_EXTRA_ARGS]
    set         scp_cmd     "scp -o StrictHostKeyChecking=no -r"
    if {$PORT != ""} {
        append  scp_cmd     " -P $PORT"
    }
    if {$KEYFILE != ""} {
        append  scp_cmd     " -i $KEYFILE"
    }
    if {$EXTRA_ARGS != ""} {
        append  scp_cmd     " $EXTRA_ARGS"
    }
    return "$scp_cmd "
}
proc scp_run {scp_cmd NODE IP} {
    start "$scp_cmd"
    expect {
            -nocase "@$IP's password: " {
                set PASS        [get_req_node_info $NODE SSH_PASS]
                send "$PASS\n"
                exp_continue -continue_timer
            }
            "%" { # Match % character from scp command to verify that the transfer(s) have started
            }
            timeout {
                fatal result FAIL "Got timeout while trying to start SCP transfer"
            }
            eof {
                fatal result FAILT "got eof while trying to start SCP transfer"
            }
    }
    set return_value [finish]
    if {$return_value != 0} {
        fatal result FAIL "Got non-zero return code $return_value for SCP-transfer"
    }
}



proc scp_put {NODE FILES TARGETDIR {USER ""} } {
    set         IP      [get_req_node_info $NODE SSH_IP]
    set         scp_cmd [scp_init $NODE]
    append scp_cmd [scp_create_file_list $FILES]
    append      scp_cmd [scp_create_remote_string $NODE $USER $TARGETDIR]
    scp_run $scp_cmd $NODE $IP
}

proc scp_get {NODE FILES TARGETDIR {USER ""} } {
    puts "$TARGETDIR $NODE $FILES $TARGETDIR $USER"

    set         scp_cmd [scp_init $NODE]

    append scp_cmd [scp_create_remote_string $NODE $USER [scp_create_file_list $FILES]]
    if { $TARGETDIR == "" } {
        fatal result FAIL "scp_get:Missing target directory"
    } else {
        append  scp_cmd " $TARGETDIR"
    }
    scp_run $scp_cmd $NODE $IP
}
