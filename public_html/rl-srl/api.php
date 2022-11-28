<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// lang
// mode
// log
// script

$lang = filter_input(INPUT_POST, "lang", FILTER_UNSAFE_RAW);
$mode = filter_input(INPUT_POST, "mode", FILTER_UNSAFE_RAW);
$log = filter_input(INPUT_POST, "log", FILTER_UNSAFE_RAW);
$script = filter_input(INPUT_POST, "script", FILTER_UNSAFE_RAW);

if (is_null($lang)) {
    $lang = "";
}
if (is_null($mode)) {
    $mode = "";
}
if ($log !== "true") {
    $log = false;
}
if (is_null($script)) {
    $script = "";
}


$timeout = 2; // seconds

$dir = dirname(__FILE__);
$cmd = "$dir/../rl-srl-apache/rl-srl-apache \"$lang\" \"$mode\" \"$log\" \"$script\"";
$dsc = array(
    0 => array('pipe','r'),
    1 => array('pipe','w')
);
$process = proc_open(
    $cmd,
    $dsc,
    $pipes,
    "/tmp",
    array()
);
proc_nice(20);
$start = time();
$output = "";

if(is_resource($process))
{
    stream_set_blocking($pipes[0], 0);
    stream_set_blocking($pipes[1], 0);

    fwrite($pipes[0], '');
    fclose($pipes[0]);
}

while(is_resource($process))
{
    $output .= stream_get_contents($pipes[1]);

    if(time() - $start > $timeout)
    {
        proc_terminate($process, 9);
        exec("pkill rl-srl-apache");
        echo json_encode(
            array(
                'error'  => 'Error: The execution timed out',
                'log'    => null,
                'output' => null
            )
        );
    }

    $status = proc_get_status($process);
    if(!$status['running'])
    {
        fclose($pipes[1]);
        proc_close($process);
	echo $output;
    }

    usleep(10000);

}

?>
