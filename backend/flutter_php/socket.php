<?php

function unmask($text) {
    $length = @ord($text[1]) & 127;
    if($length == 126) {
		$masks = substr($text, 4, 4);
		$data = substr($text, 8); 
	}
    elseif($length == 127) {
		$masks = substr($text, 10, 4);
		$data = substr($text, 14); 
	}
    else {
		$masks = substr($text, 2, 4);
		$data = substr($text, 6); 
	}
    $text = "";
    for ($i = 0; $i < strlen($data); ++$i) {
		$text .= $data[$i] ^ $masks[$i % 4];    
	}
    return $text;
}

function pack_data($text) {
    $b1 = 0x80 | (0x1 & 0x0f);
    $length = strlen($text);

    if($length <= 125) {
		$header = pack('CC', $b1, $length);
	}
        
    elseif($length > 125 && $length < 65536) {
		$header = pack('CCn', $b1, 126, $length);
	}
        
    elseif($length >= 65536) {
		$header = pack('CCNN', $b1, 127, $length);
	}
        
    return $header.$text;
}

function handshake($request_header,$sock, $host_name, $port) {
	$headers = array();
	$lines = preg_split("/\r\n/", $request_header);
	foreach($lines as $line)
	{
		$line = chop($line);
		if(preg_match('/\A(\S+): (.*)\z/', $line, $matches)){
			$headers[$matches[1]] = $matches[2];
		}
	}

    if(isset($headers['Sec-WebSocket-Key']))
        $sec_key = $headers['Sec-WebSocket-Key'];
    else
        $sec_key = $headers['sec-websocket-key'];
    $secAccept = base64_encode(pack('H*', sha1($sec_key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')));
    //hand shaking header
    // $response_header  = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n" .
    // "Upgrade: Websocket\r\n" .
    // "Connection: Upgrade\r\n" .
    // "Sec-WebSocket-Accept:$secAccept\r\n\r\n";
	$sec_accept = base64_encode(pack('H*', sha1($sec_key . '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')));
	$response_header  = "HTTP/1.1 101 Switching Protocols\r\n" .
	"Upgrade: Websocket\r\n" .
	"Connection: Upgrade\r\n" .
	"Sec-WebSocket-Accept:$sec_accept\r\n\r\n";
	socket_write($sock,$response_header,strlen($response_header));
}



$address = '0.0.0.0';
$port = 8181;
$null = NULL;

$sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
socket_set_option($sock, SOL_SOCKET, SO_REUSEADDR, 1);
socket_bind($sock, $address, $port);
socket_listen($sock);

$members = [];
$connections = [];
$connections[] = $sock;
$admin = null;
$requests = [];

echo "Listening for new connections on port $port: " . "\n";

while(true) {

    $reads = $writes = $exceptions = $connections;
    socket_select($reads, $writes, $exceptions, 0);

    if(in_array($sock, $reads)) {
        $new_connection = socket_accept($sock);
        $header = socket_read($new_connection, 1024);  
        // echo $header;  
        handshake($header, $new_connection, $address, $port);
        // echo $header;
        $connections[] = $new_connection;
        $firstIndex = array_search($sock, $reads);
        unset($reads[$firstIndex]);
    }

    foreach ($reads as $key => $value) {
        // echo "LK";
         //check for any incomming data
         $message = "";
         while($message == "")
         {
            socket_recv($value, $buf, 1024, 2);
            if(ord($buf)==136){
                break;
            }
            else $message = unmask($buf);  
         }
        //  echo $message;
        //  process text   
        if(!empty($message)) {
            // echo $message;
            $message = json_decode($message);
            if(isset($message->type)){
                if($message->type == 'request'){
                    $requests[$key] = $message->data;
                    if($admin!=null){
                        $response = pack_data(json_encode($requests));
                        socket_write($connections[$admin], $response, strlen($response));
                    }
                }else if($message->type == "verify"){
                    foreach($requests as $reqKey => $request){
                        if($request->id == $message->id){
                            $response = pack_data(json_encode(array('verified'=>true)));
                            socket_write($connections[$reqKey], $response, strlen($response));
                            unset($requests[$reqKey]);
                        }
                    }
                    if($admin!=null){
                        $response = pack_data(json_encode($requests));
                        socket_write($connections[$admin], $response, strlen($response));
                    }
                }else if($message->type == "reject"){
                    foreach($requests as $reqKey => $request){
                        if($request->id == $message->id){
                            $response = pack_data(json_encode(array('verified'=>false)));
                            socket_write($connections[$reqKey], $response, strlen($response));
                            unset($requests[$reqKey]);
                        }
                    }
                    if($admin!=null){
                        $response = pack_data(json_encode($requests));
                        socket_write($connections[$admin], $response, strlen($response));
                    }
                }else if($message->type == "getrequests"){
                    $admin = $key;
                    $response = pack_data(json_encode($requests));
                    socket_write($connections[$key], $response, strlen($response));
                }else if($message->type == "deleteallrequests"){
                    foreach($requests as $reqKey => $request){
                        if($request->accountType == $message->category){
                            $response = pack_data(json_encode(array('verified'=>false)));
                            socket_write($connections[$reqKey], $response, strlen($response));
                            unset($requests[$reqKey]);
                        }
                    }
                    if($admin!=null){
                        $response = pack_data(json_encode($requests));
                        socket_write($connections[$admin], $response, strlen($response));
                    }
                }
            } 
        }
        $check = @socket_read($value, 1024, 2) ;
         if ($check === false || ord($check) == 136) { // check disconnected client
            if($key == $admin){
                $admin = null;
            }
            unset($requests[$key]);
            unset($connections[$key]);
            if($admin!=null){
                $response = pack_data(json_encode($requests));
                socket_write($connections[$admin], $response, strlen($response));
            }
            socket_close($value);
         }
    }
    // $reads = [];
}

socket_close($sock);