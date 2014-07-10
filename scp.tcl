package provide 9pm::scp 1.0

proc scp {args} {
    if {![regexp {[a-zA-Z0-9]+:[a-zA-Z0-9/.]*} [lindex $args end]]} {
       fatal result FAIL "missing target:PATH as last argument to scp"
    }
    set NODE        [lindex [split [lindex $args end] ":"] 0]
    set REMOTEPATH  [lindex [split [lindex $args end] ":"] 1]
    set IP          [get_req_node_info $NODE SSH_IP]
    set PORT        [get_node_info $NODE SSH_PORT]
    set USER        [get_node_info $NODE SSH_USER]
    set PASS        [get_node_info $NODE SSH_PASS]
    set KEYFILE     [get_node_info $NODE SSH_KEYFILE]
    set args        [lreplace $args end end]
    set scp_cmd     "scp $DEFAULT_SSH_OPTS  -r"

    if {$PORT != ""} {
        append scp_cmd " -P $PORT"
    }
    if {$KEYFILE != ""} {
        append scp_cmd " -i $KEYFILE"
    }
    append scp_cmd " $args "
    if {$USER != ""} {
        append scp_cmd "$USER@"
    }
    append scp_cmd "$IP:$REMOTEPATH"
    start $scp_cmd
    expect {
            -nocase "@$IP's password: " {
                if {$PASS != ""} {
                    send "$PASS\n"
                } else {
                    fatal result FAIL "Got unexpected password prompt. $NODE doesnt have a password set"
                }
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
        fatal result FAIL "Got non-expected return code $return_value for SCP-transfer"
    }
}
