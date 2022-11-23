<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// lang
// mode
// log
// script

$lang = filter_input(INPUT_POST, "lang", FILTER_UNSAFE_RAW);
$mode = filter_input(INPUT_POST, "mode", FILTER_UNSAFE_RAW);
$log = filter_input(INPUT_POST, "log", FILTER_UNSAFE_RAW);
$script = filter_input(INPUT_POST, "script", FILTER_UNSAFE_RAW);

if (is_null($lang)) {
    $lang = "srl";
}
if (is_null($mode)) {
    $mode = "run";
}
if ($log !== "true") {
    $log = false;
}
if (is_null($script)) {
    $script = "";
}

$cmd = "../../rl-srl-apache/rl-srl-apache \"$lang\" \"$mode\" \"$log\" \"$script\"";
// $output = shell_exec($cmd);
// echo $output;

if (execute($cmd, $output, $output, 2) > 0) {
    echo json_encode(
        array(
            'error'  => 'Error: The execution timed out',
            'log'    => null,
            'output' => null
        )
    );
}
else {
    echo $output;
}

function execute($cmd, &$stdout, &$stderr, $timeout=false)
{
    $pipes = array();
    $process = proc_open(
        $cmd,
        array(array('pipe','w'),array('pipe','w')),
        $pipes
    );
    $pid = -1;
    $start = time();
    $stdout = '';
    $stderr = '';

    if(is_resource($process))
    {
        stream_set_blocking($pipes[0], 0);
        stream_set_blocking($pipes[1], 0);
        $pid = proc_get_status($process)['pid'];
    }

    while(is_resource($process))
    {
        //echo ".";
        $stdout .= stream_get_contents($pipes[0]);
        $stderr .= stream_get_contents($pipes[1]);

        if($timeout !== false && time() - $start > $timeout)
        {
            proc_terminate($process, 9);
            exec("pkill rl-srl-apache");
            return 1;
        }

        $status = proc_get_status($process);
        if(!$status['running'])
        {
            fclose($pipes[0]);
            fclose($pipes[1]);
            proc_close($process);
            return $status['exitcode'];
        }

        usleep(10000);
    }

    return 1;
}

?>