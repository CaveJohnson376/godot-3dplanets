extends Node

func transform_global_to_local(offset, global):
	$offset.transform = offset
	$offset/transform.global_transform = global
	return $offset/transform.transform

func transform_local_to_global(offset, local):
	$offset.transform = offset
	$offset/transform.transform = local
	return $offset/transform.global_transform

func vector_global_to_local(offset, global):
	$offset.transform = offset
	$offset/transform.global_transform.origin = global
	return $offset/transform.transform.origin

func vector_local_to_global(offset, local):
	$offset.transform = offset
	$offset/transform.transform.origin = local
	return $offset/transform.global_transform.origin
