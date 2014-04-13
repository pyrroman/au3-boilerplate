#include-once
;~ /* Copyright (C) 2000 MySQL AB

;~    This program is free software; you can redistribute it and/or modify
;~    it under the terms of the GNU General Public License as published by
;~    the Free Software Foundation; version 2 of the License.

;~    This program is distributed in the hope that it will be useful,
;~    but WITHOUT ANY WARRANTY; without even the implied warranty of
;~    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;~    GNU General Public License for more details.

;~    You should have received a copy of the GNU General Public License
;~    along with this program; if not, write to the Free Software
;~    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA */

;~ /* 
;~    Data structures for mysys/my_alloc.c (root memory allocator)
;~ */

;~ #ifndef _my_alloc_h
;~ #define _my_alloc_h

Global Const $ALLOC_MAX_BLOCK_TO_DROP			= 4096
Global Const $ALLOC_MAX_BLOCK_USAGE_BEFORE_DROP	= 10

;~ typedef struct st_used_mem /* struct for once_alloc (block) */
Global Const $st_used_mem = _
  "ptr next;" & _ ;	   /* Next block in use */
  "uint	left;" & _ ;		   /* memory left in block  */
  "uint	size;"  ;		   /* size of block */
;~ } USED_MEM;
Global Const $USED_MEM = $st_used_mem

;~ typedef struct st_mem_root
Global Const $st_mem_root = _
  "ptr free;" & _ ;                  /* blocks with free memory in it */
  "ptr used;" & _ ;                  /* blocks almost without free memory */
  "ptr preAlloc;" & _ ;             /* preallocated block */
  "" & _ ;/* if block have less memory it will be put in 'used' list */
  "uint minMalloc;" & _ ;
  "uint blockSize;" & _ ;         /* initial block size */
  "uint blockNum;" & _ ;          /* allocated blocks counter */
     "" & _ ;first free block in queue test counter (if it exceed 
     "" & _ ;MAX_BLOCK_USAGE_BEFORE_DROP block will be dropped in 'used' list)
  "uint firstBlockUsage;" & _ ;
  "ptr error_handler;"
;~ } MEM_ROOT;
Global Const $MEM_ROOT = $st_mem_root
