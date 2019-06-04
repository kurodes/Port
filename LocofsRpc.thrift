#!/usr/local/bin/thrift --gen cpp

namespace cpp LocofsRpc

struct ReadData{
	1: string buf,
	2: i64 size,
	3: i32 error,
}

struct FileAccessInode{
	1: i32 mode,
	2: i64 ctime,
	3: i64 uid,
	4: i64 gid,
	5: i32 error,
}

struct FileContentInode{
	1: i64 mtime,
	2: i64 atime,
	3: i64 size,
	4: i64 block_size,
	5: string origin_name,
	6: i32 error,
	7: i64 suuid,
    8: i64 sid,
}

struct DirectoryInode{
	1: i64 ctime,
	2: i64 mode,
	3: i64 uid,
	4: i64 gid,
	5: i64 status,
	6: string old_name,
	7: i32 error,
	8: i64 uuid,
}

struct FileInode{
	1: FileContentInode fc,
	2: FileAccessInode fa,
	3: i32 error,
}

// File Exception
exception NotFoundFileException{
	1: required string message
}
exception AlreadyExistFileException{
	1: required string message
}
exception NotAFileException{
	1: required string message
}

//Directory Exception
exception NotFoundDirectoryException{
	1: required string message
}
exception AlreayExistDirectoryException{
	1: required string message
}
exception NotADirectoryException{
	1: required string message
}

//Path Exception
exception IllegalPathException{
	1: required string message
}
exception ParentPathNotFoundException{
	1: required string message
}

//Object Exception
exception ObjectCreateException{
	1: required string message
}
exception ObjectRemoveException{
	1: required string message
}
exception ObjectNotExist{
	1: required string message
}
exception IOFailedException{
	1: required string message
}

service DataService{
	i32 write(1: string oid, 2: i64 offset, 3: i64 size, 4:string buf)
		throws (1: IOFailedException ioe, 2:ObjectCreateException oce);
	ReadData read(1:string oid, 2: i64 offset, 3: i64 size)
		throws (1: IOFailedException ioe, 2:ObjectNotExist one);
	i32 remove (1:string oid)
		throws (1: ObjectRemoveException ore);
	string read_meta(1: string st, 2: i64 offset, 3: i64 size);
	ReadData rdma_data_read(1: i64 global_address, 2: i64 size);
	i64 prealloc_space(1: string id, 2: i64 size, 3: i64 offset);
	i64 rdma_data_write(1: i64 remote_address, 2: i64 size, 3: string local_buffer);
	i64 object_write(1: string id, 2: i64 object_write_size, 3: i64 object_offset, 4: i64 remote_address)
}

service DMService{
	i32 mkdir(1:string path, 2: DirectoryInode di)
		throws (1:ParentPathNotFoundException ppe, 2:AlreayExistDirectoryException dee, 3:NotADirectoryException nae, 4:IllegalPathException ipe);

	i32 access(1:string path, 2: DirectoryInode di)
		throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);

	i32 chown(1:string path, 2: DirectoryInode di)
		throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);

	i32 chmod(1:string path, 2: DirectoryInode di)
		throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);

	i32 rmdir(1:string path, 2: DirectoryInode di)
		throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);

	i32 rename(1:string old_path, 2:string new_path)
		throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);

	DirectoryInode getAttr(1:string path, 2:DirectoryInode di)
			throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);

	binary readdir(1: string path)
		throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);

    i32 opendir(1: string path, 2: DirectoryInode di)
        throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);
}

service FMService{
	i32 create(1: string path, 2: FileAccessInode fa)
		throws (1:AlreadyExistFileException aee, 2: NotAFileException nfe);

	FileInode open(1: string path, 2: FileAccessInode fa);

	i32 access(1: string path, 2: FileAccessInode fa)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	i32 chown(1: string path, 2: FileAccessInode fa)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	i32 chmod(1: string path, 2: FileAccessInode fa)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	i32 remove(1: string path, 2: FileAccessInode fa)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	i32 csize(1:string path, 2: FileContentInode fc)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	FileInode getAttr(1:string path, 2:FileInode fi)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	FileContentInode getContent(1:string path, 2: FileContentInode fi)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	FileAccessInode getAccess(1:string path, 2: FileAccessInode fa)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

 	binary readdir(1: i64 uuid)
		throws (1: NotADirectoryException nde);

	i32 utimens(1:string path, 2:FileContentInode fc)
		throws (1:NotFoundFileException aee, 2: NotAFileException nfe);

	i32 rename(1:string old_path, 2:string new_path)
		throws (1: ParentPathNotFoundException ppe, 2: NotFoundDirectoryException dee, 3: NotADirectoryException nde, 4: IllegalPathException ipe);
}

